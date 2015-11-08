class RobotCatcherFormBuilder < ActionView::Helpers::FormBuilder 
  def robot_tags(ip)
    @timestamp = Time.now.to_i.to_s
    @spinner   = Digest::MD5.hexdigest(@timestamp + ip.to_s + "robot_catcher")

    hidden_field :timestamp, :value => @timestamp
    hidden_field :spinner, :value => @spinner
  end

  def self.create_tagged_field(method_name)
    define_method(method_name) do |label, *args|
      hash_tag = Digest::MD5.hexdigest(label + @spinner + "robot_catcher")
      text_field hash_tag, { :value => "", :style => "display:none;" }
      super(label, *args)
    end

    field_helpers.each do |name|
      create_tagged_field(name)
    end
  end
end