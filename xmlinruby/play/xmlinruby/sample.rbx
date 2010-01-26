class MyView < View
  def index(title)
    <html>
      <head>
        <title>${title}</title> 
      </head>
      <body>
        render_body
      </body>
    </html>
  end

  def render_body
    output "Hello World"
  end
end

puts MyView.render(:index, "Test")
