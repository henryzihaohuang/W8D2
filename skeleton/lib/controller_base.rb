require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @res = res
    @req = req
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
    
  end

  # Set the response status code and header
  def redirect_to(url)
    @res['location'] = url
    @res.status = 302

    if already_built_response?
      raise 'double render'
    else
      @already_built_response = true
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true

  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    content = File.dirname(__FILE__)
    template_fname = File.join(
      content, "..",
      "views", self.class.name.underscore, "#{template_name}.html.erb"
    )

    template_code = File.read(template_fname)

    render_content(
      ERB.new(template_code).result(binding),
      "text/html"
    )
    
  end

  # method exposing a `Session` object
  def session
      @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end


  
end

