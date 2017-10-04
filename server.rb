# myapp.rb
require 'sinatra'
require 'sqlite3'

class Server
  def initialize
    @@db = SQLite3::Database.new("db/pizza.db")
  end

  def home(params = {})
    [:home, locals: {errors: []}]
  end

  def order(params = {})
    errors = []
    errors << 'Preciso saber seu nome!' if blank?(params['name'])
    errors << 'Preciso saber qual pizza você quer!' if blank?(params['first_pizza'])
    return [:home, locals: {errors: errors}] if !errors.empty?

    order1 = insert_order(params['name'], params['first_pizza'])
    order2 = insert_order(params['name'], params['second_pizza']) if present?(params['second_pizza'])

    [:thanks, locals: {orders: [order1, order2].compact}]
  end

  def list(params = {})
    orders = @@db.execute('select name, pizza, ordered_at from orders where ordered_at > ?;',
                          (Time.now - 24*60*60).to_s) # one day ago
    [:list, locals: {orders: orders}]
  end

  private
  def insert_order(name, pizza)
    @@db.execute('insert into orders (name, pizza, ordered_at) values (?, ?, ?);',
                 name,
                 pizza,
                 Time.now.to_s)
    @@db.execute('select last_insert_rowid() from orders;').first.first
  end

  def present?(arg)
    arg && arg!=''
  end

  def blank?(arg)
    !present?(arg)
  end
end

server = Server.new

get '/' do
  erb *server.home(params)
end

post '/pedido' do
  erb *server.order(params)
end

get '/lista' do
  erb *server.list(params)
end
