# frozen_string_literal: true

class ProductParserRulesController < ApplicationController
  before_action :set_product_parser_rule, only: %i[show edit update destroy]
  before_action :set_product


  # GET /product_parser_rules or /product_parser_rules.json
  def index
    @product_parser_rules = ProductParserRule.all
  end

  # GET /product_parser_rules/1 or /product_parser_rules/1.json
  def show; end

  # GET /products/:product_id/product_parser_rules/new
  def new
    @product_parser_rule = @product.product_parser_rules.build
  end

  # GET /product_parser_rules/1/edit
  def edit; end

  # POST /products/:product_id/product_parser_rules
  def create
    pp 'sfsdfafd'
    @product_parser_rule = @product.product_parser_rules.build(product_parser_rule_params)

    respond_to do |format|
      if @product_parser_rule.save
        format.html { redirect_to product_parser_rule_url(@product_parser_rule), notice: 'Product parser rule was successfully created.' }
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
        format.html { redirect_to product_parser_rule_url(@product_parser_rule), notice: 'Product parser rule was successfully updated.' }
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

  private

  def set_product
    @product = Product.find(params[:product_parser_rule][:product_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_product_parser_rule
    @product_parser_rule = ProductParserRule.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_parser_rule_params
    params.require(:product_parser_rule).permit(:url, :selector)
  end
end
