class ItemsController < ApplicationController
  before_action :set_item, except: [:index, :new, :create, :get_category_children, :get_category_grandchildren]
  before_action :show_all_instance, only: [:show, :edit, :update, :destroy]
  def index
    @items = Item.includes(:images).order('items.created_at DESC').limit(5).where.not(sellstatus_id: 2).where(sellstatus_id: 1)
    @parent = Category.where(ancestry: nil)
  end

  def new
    if user_signed_in?
    else
      redirect_to root_path
    end
    @item = Item.new
    @item.images.new #-商品出品時に画像も同時に保存されるように記述
    @item.build_brand #-商品出品時にブランドも同時に保存されるように記述
    @category_parent_array = Category.where(ancestry: nil) #-カテゴリ親要素呼び出し
  end

  def create
    @item = Item.new(item_params)
    @item.user_id = current_user.id
    if @item.save
      item = Item.find(@item.id)
      redirect_to root_path
    else
      @item.images.new #-商品出品時に画像も同時に保存されるように記述
      @item.build_brand #-商品出品時にブランドも同時に保存されるように記述
      @category_parent_array = Category.where(ancestry: nil) #-カテゴリ親要素呼び出し
      render :new
    end
  end

  def edit
    if user_signed_in?
      if current_user.id == @item.saler_id
        @category_parent_array = Category.where(ancestry: nil) #-カテゴリ親要素呼び出し
        @category_child_array = @category_parent.children
        @category_grandchild_array = @category_child.children
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end 
  end

  def update
    @category_parent_array = Category.where(ancestry: nil) #-カテゴリ親要素呼び出し
    @category_child_array = @category_parent.children
    @category_grandchild_array = @category_child.children
    if @item.update(item_params)
      redirect_to root_path
    else
      render :edit
    end
  end


  def destroy
    if  @item.destroy
      redirect_to root_path
    else
      flash.now[:alert] = '削除できませんでした'
      render :show
    end
  end
  
  def show
  end

  def get_category_children #-カテゴリ子要素呼び出し
    @category_children = Category.find(params[:parent_id]).children
  end

  def get_category_grandchildren #-カテゴリ孫要素呼び出し
    @category_grandchildren = Category.find(params[:child_id]).children
  end 

  private
  def item_params
    params.require(:item).permit(:saler_id, :name, :introduction, :sellstatus_id, :prefecture_id, :price, :condition_id, :postagepayer_id, :postagetype_id, :preparationdays_id, :category_id, :size, images_attributes: [:src, :_destroy, :id], brand_attributes: [:id, :_destroy, :name])
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def show_all_instance
    @user = User.find(@item.user_id)
    @images = Image.where(item_id: params[:id])
    @images_first = Image.where(item_id: params[:id]).first
    @category_id = @item.category_id
    @category_parent = Category.find(@category_id).parent.parent
    @category_child = Category.find(@category_id).parent
    @category_grandchild = Category.find(@category_id)
  end
end
