module ApplicationHelper
  def rc_form_for(name, *args, &block)
    options = args.extract_options!

    form_for(name, *(args << options.merge(:builder => RobotCatcherFormBuilder)), &block)
  end
end
