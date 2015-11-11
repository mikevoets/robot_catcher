module RobotCatcher
  module Helpers
    class FormBuilder < ActionView::Helpers::FormBuilder 
      def initialize(object_name, object, template, options)        
        @spinner = options[:spinner]
        super(object_name, object, template, options, nil)
      end

      def self.create_tagged_field(method_name)
        define_method(method_name) do |label, *args|
          if method_name.eql? "label"
            super(label, *args)
          else
            hash_tag = Digest::MD5.hexdigest(label.to_s + @spinner + "robotcatcher")
            @template.text_field_tag(hash_tag, nil, :style=>"display:none") +
             super(label, *args)
          end
        end
      end

      field_helpers.each do |name|
        create_tagged_field(name)
      end
    end

    module FormTagHelper
      extend ActiveSupport::Concern

      included do 
        class_attribute :field_tag_helpers
        self.field_tag_helpers = [:rc_text_field_tag, :rc_password_field_tag, :rc_range_field_tag,
                                :rc_hidden_field_tag, :rc_file_field_tag, :rc_text_area_tag,
                                :rc_check_box_tag, :rc_radio_button_tag, :rc_color_field_tag,
                                :rc_search_field_tag, :rc_telephone_field_tag, :rc_phone_field_tag,
                                :rc_date_field_tag, :rc_time_field_tag, :rc_datetime_field_tag,
                                :rc_datetime_local_field_tag, :rc_month_field_tag, :rc_week_field_tag,
                                :rc_url_field_tag, :rc_email_field_tag, :rc_number_field_tag]

        def self.create_tagged_field_tag(method_name, parent_method)
          define_method(method_name) do |label, *args|
            hash_tag = Digest::MD5.hexdigest(label.to_s + @spinner + "robotcatcher")
            text_field_tag(hash_tag, nil, :style=>"display:none") + 
             self.send(parent_method, label, *args)
          end
        end
            
        field_tag_helpers.each do |name|
          create_tagged_field_tag(name, name.to_s.sub(/rc_/, '').to_sym)
        end

        # (field_tag_helpers - [:check_box_tag, :radio_button_tag, :hidden_field_tag, :file_field_tag]).each do |selector|
        #   class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        #     def #{selector}(method, options = {})  # def text_field_tag(method, options = {})
        #       self.send(                           #   self.send(
        #         #{selector.inspect},               #     "text_field_tag",
        #         method)                            #     method)
        #     end                                    # end
        #   RUBY_EVAL
        # end
      
        def rc_form_tag(url_for_options = {}, options = {}, &block)
          if !options.has_key? :ip
            raise ArgumentError, "should include ip address"
          end
          ip = options.delete(:ip)

          timestamp = Time.now.to_i.to_s
          # p "To be spinned (front-end): #{timestamp}#{ip}robotcatcher"
          @spinner = Digest::MD5.hexdigest(timestamp + ip.to_s + "robotcatcher")

          options[:spinner] = @spinner

          html_options = options[:html] ||= {}

          html_options[:data]   = options.delete(:data)   if options.has_key?(:data)
          html_options[:remote] = options.delete(:remote) if options.has_key?(:remote)
          html_options[:method] = options.delete(:method) if options.has_key?(:method)
          html_options[:enforce_utf8] = options.delete(:enforce_utf8) if options.has_key?(:enforce_utf8)
          html_options[:authenticity_token] = options.delete(:authenticity_token)

          builder = RobotCatcher::Helpers::FormBuilder.new(nil, nil, self, options)
          content = capture(builder, &block)
          html_options[:multipart] ||= builder.multipart?

          html_options = html_options_for_form(url_for_options, html_options)
          
          if block_given?
            output = form_tag_html(html_options)
            output.safe_concat(hidden_field_tag(:timestamp, timestamp))
            output.safe_concat(hidden_field_tag(:spinner, @spinner))
            output << content
            output.safe_concat("</form>")
          else
            output = form_tag_html(html_options)
            output.safe_concat(hidden_field_tag(:timestamp, timestamp))
            output.safe_concat(hidden_field_tag(:spinner, @spinner))
          end
        end
      end
    end

    module FormHelper
      extend ActiveSupport::Concern

      included do
        def rc_form_for(record, *args, &block)
          options = args.extract_options!
          if !options.has_key? :ip
            raise ArgumentError, "should include ip address"
          end
          ip = options.delete(:ip)
          
          timestamp = Time.now.to_i.to_s
          # p "To be spinned (front-end): #{timestamp}#{ip}robotcatcher"
          spinner = Digest::MD5.hexdigest(timestamp + ip.to_s + "robotcatcher")
          
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
            object_name = options[:as] || object.class.name.downcase
            apply_form_for_options!(record, options)
          end

          html_options[:data]   = options.delete(:data)   if options.has_key?(:data)
          html_options[:remote] = options.delete(:remote) if options.has_key?(:remote)
          html_options[:method] = options.delete(:method) if options.has_key?(:method)
          html_options[:enforce_utf8] = options.delete(:enforce_utf8) if options.has_key?(:enforce_utf8)
          html_options[:authenticity_token] = options.delete(:authenticity_token)

          builder = RobotCatcher::Helpers::FormBuilder.new(object_name, object, self, options)
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
end

ActionView::Helpers::FormTagHelper.send :include, RobotCatcher::Helpers::FormTagHelper
ActionView::Helpers::FormHelper.send :include, RobotCatcher::Helpers::FormHelper