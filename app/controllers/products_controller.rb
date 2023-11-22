# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy prices_chart]

  add_breadcrumb 'Список товаров', :root_path

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
    add_breadcrumb @product.title
  end

  # GET /products/new
  def new
    add_breadcrumb 'Новый товар'
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
    add_breadcrumb @product.title, @product
    add_breadcrumb 'Редактирование'
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)
    @product.period_lowest_price = Product.period_lowest_prices[params[:product][:period_lowest_price]]

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    @product.period_lowest_price = Product.period_lowest_prices[params[:product][:period_lowest_price]]
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def prices_chart
    grouped_by_rules = {}
    period_lowest_price = Product.period_lowest_prices[@product.period_lowest_price].to_i.days.ago
    sql = "SELECT strftime('%d.%m.%Y', prices.created_at) as date_day, MIN(prices.value) as min_price, rules.url
            FROM products
            JOIN product_parser_rules rules ON products.id = rules.product_id
            JOIN prices ON prices.product_parser_rule_id = rules.id
            WHERE products.id = ? AND prices.created_at BETWEEN ? AND date('now')
            GROUP BY date_day
            ORDER BY prices.created_at ASC"
    Product.execute_sql(sql, @product.id, period_lowest_price).each do |record|
      grouped_by_rules[record['url']] = {} if grouped_by_rules[record['url']].nil?
      grouped_by_rules[record['url']][record['date_day']] = record['min_price']
    end
    @data = []
    grouped_by_rules.each do |rule_url, rule_data|
      @data << { name: rule_url, data: rule_data}
    end

    render json: @data.chart_json
    # render turbo_stream: turbo_stream.append('prices-chart', partial: 'prices-chart')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:title, :description)
  end
end
