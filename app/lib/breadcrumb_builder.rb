# frozen_string_literal: true

class BreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder

  def render
    @elements.collect do |element|
      render_element(element)
    end.join(@options[:separator])
  end

  def render_element(element)
    item_class = 'breadcrumb-item'
    content = if @context.request.post? # Force the last breadcrumb to be the active one if the request is a post
                @elements.last == element ? element.name : @context.link_to(compute_name(element), compute_path(element))
              else
                @context.link_to_unless_current(compute_name(element), compute_path(element))
              end

    if @options[:tag]
      @context.content_tag(@options[:tag], content, class: [item_class, {active: @elements.last == element}])
    else
      content
    end
  end
end
