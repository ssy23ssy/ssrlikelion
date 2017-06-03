class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index

    if params[:s_type].present?

      @s_type = params[:s_type]
      @search = params[:search]
      @utf8 = params[:utf8]
      case @s_type
        when "s_title"
          @posts = Post.paginate(:page => params[:page]).where("content like ?", "%" + @search.to_s + "%").recent
        when "s_writer"
          @posts = Post.paginate(:page => params[:page]).where("writer like ?", "%" + @search.to_s + "%").recent
        else
          redirect_to root_path
      end

    else

      @posts = Post.paginate(:page => params[:page]).recent

    end
    @page = params[:page]

  end

  def new
    @post = Post.new
  end

  def show

    @s_type = params[:s_type]
    @search = params[:search]
    @utf8 = params[:utf8]

    # includes로 미리 comments 받아와서 show에서 댓글 each문 돌릴 때 불필요하게 쿼리문을 여러번 안날리게끔 함
    @post = Post.includes(:comments).find(params[:id])
    @page = params[:page]

    @next_post_id = next_post_id(@post.id, @search, @s_type)
    @previous_post_id = previous_post_id(@post.id, @search, @s_type)
  end

  def create
    # posts = Post.new(title: params[:title], content: params[:content])
    # posts.save

    # Post.create(title: params[:title], content: params[:content])

    user = User.find(current_user.id)
    post = user.posts.new(post_new_params)
    post.writer = user.name

    if params[:post][:image].present?
      imageuploader = ImageUploader.new
      imageuploader.store!(params[:post][:image]) # s3에 저장
      post.image = imageuploader.url # s3에 들어간 사진의 url 넣어줌
    end

    if post.save
      redirect_to post
    else
      redirect_to new_post_path # 이렇게 하면 요청이 한번 더 가서 render 'new'로 하는게 좋다고함
    end

  end

  def edit
    @post = Post.find(params[:id])
    if @post.user == current_user
      @page = params[:page]
      @s_type = params[:s_type]
      @search = params[:search]
      @utf8 = params[:utf8]
    else
      redirect_to root_path
    end
  end

  def update

    post = Post.find(params[:id])

    if post.user == current_user

      # 파일 업로드가 없으면 본문과 제목만 수정
      if params[:post][:image].nil?
        post.update(post_edit_params)
      else # 있으면 파일도 수정
        imageuploader = ImageUploader.new
        imageuploader.store!(params[:post][:image])
        post.image = imageuploader.url
        post.update(post_edit_params)
      end

      s_type = params[:s_type]
      search = params[:search]
      utf8 = params[:utf8]
      page = params[:page]
      page = 1 if page.blank?
      redirect_to post_path(post, page: page, search: search, s_type: s_type, utf8: utf8)

    else
      redirect_to root_path
    end

  end

  def destroy
    post = Post.find(params[:id])

    if post.user == current_user
      # 포스트에 딸린 코멘츠를 프로그래밍적으로 삭제, 모델에서 dependent: :destroy 하면 데이터베이스측면에서 삭제하는 것
      # post.comments.destroy_all
      post.destroy
      redirect_to root_path
    else
      redirect_to root_path
    end
  end


  private

  def next_post_id(current_id, search, s_type)

    case s_type
      when "s_title"
        post = Post.get_next_post_s_title(current_id, search)
        post.nil? ? nil : post.id
      when "s_writer"
        post = Post.get_next_post_s_writer(current_id, search)
        post.nil? ? nil : post.id
      else
        post = Post.get_next_post(current_id)
        post.nil? ? nil : post.id
    end

  end

  def previous_post_id(current_id, search, s_type)

    case s_type
      when "s_title"
        post = Post.get_previous_post_s_title(current_id, search)
        post.nil? ? nil : post.id
      when "s_writer"
        post = Post.get_previous_post_s_writer(current_id, search)
        post.nil? ? nil : post.id
      else
        post = Post.get_previous_post(current_id)
        post.nil? ? nil : post.id
    end

  end

  def post_new_params
    params.require(:post).permit(:title, :content)
  end

  def post_edit_params
    params.require(:post).permit(:title, :content)
  end

  # def post_image_params
  #   params.require(:post).permit(:image) # 이미지는 이렇게하면 걸러져 버림...
  # end
end

=begin

client = Client.first (클라이트 테이블의 첫번째 row를 객체화해서 갖고옴)

-----객체화(내가 생각해본 대략적인 예상도)-----
class Client

# 해당 하는 요소들에 대해서 읽고 쓰기 가능
attr_accessor :id, :first_name, :created_time
# -------------------------------------------
# attr_accessor :first_name
#
# ==
#
# def first_name
#   @first_name
# end
#
# def first_name=(str)
#   @first_name = str
# end
# -------------------------------------------

  # @id => SELECT id FROM clients WHERE id = 1 LIMIT 1
  # @first_name => SELECT first_name FROM clients WHERE id = 1 LIMIT 1
  # @created_time => SELECT created_time FROM clients WHERE id = 1 LIMIT 1

  # 실제로는 이렇게 따로 정의되어 있는것이 아니고 존재하는 칼럼에 따라서 자동으로 매소드를 생성해주게끔 만들어지지 않을까 싶음

end

=end