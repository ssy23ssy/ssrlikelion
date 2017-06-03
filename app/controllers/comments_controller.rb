class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = User.find(current_user.id)
    post = Post.find(params[:post_id])
    comment = post.comments.new(comment_params)
    comment.user_id = user.id
    comment.writer = user.name

    comment.save

    redirect_back(fallback_location: post_path(id: params[:post_id]))
  end

  def destroy
    post = Post.find(params[:post_id])
    comment = post.comments.find(params[:id])
    if current_user == comment.user
      comment.destroy
      redirect_back(fallback_location: post_path(id: post.id))
    else
      redirect_to root_path
    end

  end

  private
  def comment_params
    params.require(:comment).permit(:writer, :content, :user_id)
    # 유저아이디는 integer형식인데 string으로 넘어와서 안들어가는 듯
  end
end
