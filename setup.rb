require 'sqlite3'

DB = SQLite3::Database.new("db/pizza.db")

DB.execute('drop table if exists orders;')
DB.execute('create table orders (id integer primary key, name string, pizza string, ordered_at timestamp);')
