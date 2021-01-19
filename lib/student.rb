require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.find_by_name == false
      insertion = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
      DB[:conn].execute(insertion, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      update
    end
  end

  # def save
  #   sql = <<-SQL
  #   INSERT INTO students (name, grade) 
  #   VALUES (?, ?)
  #   SQL

  #   DB[:conn].execute(sql, self.name, self.grade)
  #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  # end

  def self.create(name,grade)
    self.new
    save
  end

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.find_by_name
    sql = "SELECT * FROM students WHERE name = ?"
    result = DB[:conn].execute(sql, @name)[0]
    result.length > 0 ? result : false
  end

  def update
    sql = "SELECT id FROM students WHERE name = ?"
    @id = DB[:conn].execute(sql, @name)[0][0]
    update = <<-SQL
    UPDATE students name = ?, grade = ? WHERE name = ?
    SQL
    DB[:conn].execut(update, @name, @grade, @name)
  end

end
