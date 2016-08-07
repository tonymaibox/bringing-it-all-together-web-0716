require 'pry'

class Dog

	attr_accessor :name, :breed, :id

	def initialize(name: nil, breed: nil, id: nil)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
		CREATE TABLE IF NOT EXISTS dogs (
		id INTEGER PRIMARY KEY,
		name TEXT,
		breed TEXT);
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL 
		DROP TABLE dogs
		SQL

		DB[:conn].execute(sql)
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL 
			INSERT INTO dogs
			(name, breed)
			VALUES
			(?, ?);
			SQL

			DB[:conn].execute(sql, self.name, self.breed)

			sql = <<-SQL
			SELECT *
			FROM dogs
			ORDER BY id DESC
			LIMIT 1;
			SQL

			resultid = DB[:conn].execute(sql)
			@id = resultid.flatten.first
			self
		end
	end

	def self.create(name:, breed:)
		# binding.pry
		dog = Dog.new(name: name, breed: breed)
		dog.save
		# dog
	end

	def self.new_from_db(row)
		new_dog = self.new
	    new_dog.id = row[0]
    	new_dog.name = row[1]
    	new_dog.breed = row[2]
    	new_dog
	end

	def self.find_by_id(id)
		sql = <<-SQL
	    SELECT *
	    FROM dogs
	    WHERE id = ?
	    SQL

	    row = DB[:conn].execute(sql,id).first
	    self.new_from_db(row)
	end

	def self.find_by_name(name)
		sql = <<-SQL
	    SELECT *
	    FROM dogs
	    WHERE name = ?
	    SQL

	    row = DB[:conn].execute(sql,name).first
	    self.new_from_db(row)
	end		

	def update
	  	sql = <<-SQL
	  	UPDATE dogs
	  	SET name = ?, breed = ?
	  	WHERE id = ?;
	  	SQL

	  	DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	def self.find_or_create_by(name:, breed:)
		# binding.pry
		if self.find_by_name(name).breed == breed
			self.find_by_name(name)
		else
			self.create(name: name, breed: breed)
		end
	end

end