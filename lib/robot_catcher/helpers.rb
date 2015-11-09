module RobotCatcher
  module Helpers
    class FormBuilder < ActionView::Helpers::FormBuilder 
      def initialize(object_name, object, template, options)        
        @spinner = options[:spinner]
        super(object_name, object, template, options)
      end

      def self.create_tagged_field(method_name)
        define_method(method_name) do |label, *args|
          if method_name.eql? :label
            super(label, *args)
          else
            hash_tag = Digest::MD5.hexdigest(label.to_s + @spinner + "robot_catcher")
            @template.text_field_tag(hash_tag, nil, :style=>"display:none") +
             super(label, *args)
           end
        end
      end

      field_helpers.each do |name|
        create_tagged_field(name)
      end
    end

    module FormHelper
      def robot_catcher_form_for(record, ip, *args, &block)
        options = args.extract_options!
        options[:builder] = RobotCatcher::Helpers::FormBuilder
        
        timestamp = Time.now.to_i.to_s 
        spinner = Digest::MD5.hexdigest(timestamp + ip.to_s + "robot_catcher")
        options[:spinner] = spinner

        raise ArgumentError, "Missing block" unless block_given?
        html_options = options[:html] ||= {}

        case record
        when String, Symbol
          object_name = record
          object      = nil
        else
          object      = record.is_a?(Array) ? record.last : record
          raise ArgumentError, "First argument in form cannot contain nil or be empty" unless object
          object_name = options[:as] || model_name_from_record_or_class(object).param_key
          apply_form_for_options!(record, object, options)
        end

        html_options[:data]   = options.delete(:data)   if options.has_key?(:data)
        html_options[:remote] = options.delete(:remote) if options.has_key?(:remote)
        html_options[:method] = options.delete(:method) if options.has_key?(:method)
        html_options[:enforce_utf8] = options.delete(:enforce_utf8) if options.has_key?(:enforce_utf8)
        html_options[:authenticity_token] = options.delete(:authenticity_token)

        builder = instantiate_builder(object_name, object, options)
        content = capture(builder, &block)
        html_options[:multipart] ||= builder.multipart?

        html_options = html_options_for_form(options[:url] || {}, html_options)
        
        output = form_tag_html(html_options)
        output.safe_concat(hidden_field_tag(:timestamp, timestamp))
        output.safe_concat(hidden_field_tag(:spinner, spinner))
        output << content
        output.safe_concat("</form>")
      end
    end

  end
end

ActionView::Helpers::FormHelper.send :include, RobotCatcher::Helpers::FormHelper