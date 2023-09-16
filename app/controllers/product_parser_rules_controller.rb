# frozen_string_literal: true

class ProductParserRulesController < ApplicationController
  before_action :set_product_parser_rule, only: %i[show edit update destroy check]
  before_action :set_product, only: %i[new create]
  before_action :cookies_to_json, only: %i[edit show]
  add_breadcrumb 'Список товаров', :root_path

  # GET /product_parser_rules or /product_parser_rules.json
  def index
    @product = Product.eager_load(:product_parser_rules, :prices).where(id: params[:product_id]).sole
    @product_parser_rules = @product.product_parser_rules
    add_breadcrumb @product.title, @product
    add_breadcrumb 'Cписок правил'
  end

  # GET /product_parser_rules/1 or /product_parser_rules/1.json
  def show
    @product = @product_parser_rule.product

    raise RecordNotFound("Не найден товар c ID #{@product_parser_rule.product_id}") unless @product

    add_breadcrumb @product.title, @product
    add_breadcrumb 'Список правил', product_product_parser_rules_path(@product)
    add_breadcrumb 'Правило'
  end

  # GET /products/:product_id/product_parser_rules/new
  def new
    add_breadcrumb "Новое правило для #{@product.title}"
    @product_parser_rule = @product.product_parser_rules.build
  end

  # GET /product_parser_rules/1/edit
  def edit
    product = @product_parser_rule.product
    add_breadcrumb(product.title, product)
    add_breadcrumb @product_parser_rule.url.truncate(50), @product_parser_rule
    add_breadcrumb 'Редактирование'
  end

  # POST /products/:product_id/product_parser_rules
  def create
    @product_parser_rule = @product.product_parser_rules.build(product_parser_rule_params)

    respond_to do |format|
      if @product_parser_rule.save
        format.html do
          redirect_to product_parser_rule_url(@product_parser_rule),
                      notice: 'Product parser rule was successfully created.'
        end
        format.json { render :show, status: :created, location: @product_parser_rule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product_parser_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_parser_rules/1 or /product_parser_rules/1.json
  def update
    respond_to do |format|

      if @product_parser_rule.update(product_parser_rule_params)
        format.html do
          redirect_to product_parser_rule_url(@product_parser_rule),
                      notice: 'Product parser rule was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @product_parser_rule }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product_parser_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_parser_rules/1 or /product_parser_rules/1.json
  def destroy
    @product_parser_rule.destroy

    respond_to do |format|
      format.html { redirect_to product_parser_rules_url, notice: 'Product parser rule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /product_parser_rules/1/check
  def check
    parser = Parser::ProductPageParser.new(@product_parser_rule.url, timeout: @product_parser_rule.waits_timeout, cookies: @product_parser_rule.cookies)
    result = parser.get_value(@product_parser_rule.selector)
    @data = if result.success?
              result.value!
            else
              result.failure
            end
    render turbo_stream: turbo_stream.append('parse-result', partial: 'check')
  end

  private

  def set_product
    # TODO: доработать
    @product = Product.find(params.include?(:product_parser_rule) ? params[:product_parser_rule][:product_id] : params[:product_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_product_parser_rule
    @product_parser_rule = ProductParserRule.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_parser_rule_params
    params.require(:product_parser_rule).permit(:url, :selector, :waits_timeout, :active, :cookies)
  end

  def cookies_to_json
    @product_parser_rule.cookies = @product_parser_rule.cookies.to_json if @product_parser_rule.cookies.is_a?(Hash)
  end
end
