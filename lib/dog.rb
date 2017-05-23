class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.new_from_db(row)
    attributes = {id:row[0], name:row[1], breed:row[2]}
    Dog.new(attributes)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, [name, breed])

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL

    DB[:conn].execute(sql, [name, breed, id])
  end

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    row = DB[:conn].execute(sql, [id]).first
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL

    row = DB[:conn].execute(sql, [attributes[:name], attributes[:breed]]).first

    if row.nil?
      Dog.new(attributes).save
    else
      Dog.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name).first
    Dog.new_from_db(row)
  end

end #dog class
