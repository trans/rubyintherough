require 'markups/template'

s = <<-END

--- !!template

main.foo: !!table

  picture: |
    +-------------+---------+
    | a.test      |    b    |
    +-------------+---------+
    | x           |    y    |
    | width="40%" |         |
    +-------------+---------+

x:
  - !!paragraph
    text: "Hello, World!"
    width: 50%

#--- !!stylesheet
#
#style:
#  main:
#    width: 100%

END

tmpl = MarkUps.parse(s)
puts tmpl.to_html


s = %{

    main.foo width=50% background:red
    +----------------+---------+
    | a.test         |    b    |
    |                |         |
    | "Hi"           |         |
    |                |         |
    +----------------+---------+
    |                |         |
    | x              |    y    |
    +----------------+---------+

    a width=50%
    "Hi"

    x
    "Hello, World"

    b
    +------+------+
    |  z1  |  z2  |
    +------+------+

    y
    # yli "Dummy Data"

}


s = %{

    <main class="foo" style="background:red;">
      +----------------+---------+
      | a.test         |    b    |
      |                |         |
      | "Hi"           |         |
      |                |         |
      +----------------+---------+
      |                |         |
      | x              |    y    |
      +----------------+---------+
    </main>

    <a class="test" width="50%">
      "Hi"
    </a>

    <x>"Hello, World"</x>

    <b>
    +------+------+
    |  z1  |  z2  |
    +------+------+
    </b>

    <y>
      <ul>
      <li id="yli">Dummy Data</li>
      </ul>
    </y>

}
