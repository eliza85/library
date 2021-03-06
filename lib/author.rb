class Author
  attr_accessor :name, :id

  def initialize(attributes)
    @name = attributes.fetch(:name, nil)
    @id = attributes.fetch(:id, nil)
  end

  def self.all
    returned_authors = DB.exec('SELECT * FROM authors;')
    authors = []
    returned_authors.each() do |author|
      name = author.fetch('name')
      id = author.fetch('id').to_i
      authors.push(Author.new({:name => name, :id => id}))
    end
    authors
  end

  def self.search(x)
    authors = Author.all
    authors.select {|e| /#{x}/i.match? e.name}
  end

  def save
    result = DB.exec("INSERT INTO authors (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def ==(author_to_compare)
    self.name() == author_to_compare.name()
  end

  def self.clear
    DB.exec("DELETE FROM authors *;")
  end

  def self.find(id)
    author = DB.exec("SELECT * FROM authors WHERE id = #{id};").first
    name = author.fetch("name")
    id = author.fetch("id").to_i
    Author.new({:name => name, :id => id})
  end

  def update(name)
    @name = name
    DB.exec("UPDATE authors SET name = '#{@name}' WHERE id = #{@id}")
  end

  def delete
    DB.exec("DELETE FROM authors WHERE id = #{@id};")
    DB.exec("DELETE FROM books WHERE authors_id = #{@id};")
  end

  def self.sort()
    authors = Author.all
    authors.sort { |a, b| a.name <=> b.name }
  end

  def books
    Book.find_by_author(self.id)
  end

  def add_book(book_name)
    book = Book.search(book_name).first
    DB.exec("INSERT INTO authors_books (book_id, author_id) VALUES (#{book.id}, #{@id})")
  end
# def artists
#   Artist.find_by_album(self.id)
# end
#

end
