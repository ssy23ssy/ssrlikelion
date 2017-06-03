class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  belongs_to :user
  self.per_page = 5


  # 최신순 정렬
  # def self.recent
  #   order(created_at: :desc)
  # end
  scope :recent, -> { order(created_at: :desc) }

  # 다음 게시글 아이디
  def self.get_next_post(current_id)
    where("id > ?", current_id).first
  end

  def self.get_next_post_s_title(current_id, search)
    where("id > ? and title like ?", current_id, "%"+search.to_s+"%").first
  end

  def self.get_next_post_s_writer(current_id, search)
    where("id > ? and writer like ?", current_id, "%"+search.to_s+"%").first
  end

  # 이전 게시글 아이디
  def self.get_previous_post(current_id)
    where("id < ?", current_id).last
  end

  def self.get_previous_post_s_title(current_id, search)
    where("id < ? and title like ?", current_id, "%" + search.to_s + "%").last
  end

  def self.get_previous_post_s_writer(current_id, search)
    where("id < ? and writer like ?", current_id, "%" + search.to_s + "%").last
  end


  # 스코프로 정의하지 않은 이유

  # !!!! 스코프로 정의했을 때 가장 처음글의 아이디보다 작은 글을 찾으면 nil이여하는데,
  # SELECT "posts".* FROM "posts" 이게 날아가서 전부 받아옴

  # 스코프는 chainability를 위해 nil이나 blank를 반환하지 않고 항상 relation을 반환한다!
  # 그래서 nil이나 blank가 나오면 모든것을 반환해버림. 스코프를 클래스 매소드로 나타내면 이렇게 생김,

  # ex1)
  # def self.get_previous_post(current_id)
  #   if where("id < ?", current_id).last.present?
  #     where("id < ?", current_id).last
  #   else
  #     all
  #   end
  # end
  #
  # ex2)
  # def self.by_status(status)
  #   if status.present?
  #     where(status: status)
  #   else
  #     all
  #   end
  # end

  # So the advice here is: never return nil from a class method that should work like a scope,
  # otherwise you’re breaking the chainability condition implied by scopes, that always return a relation.

  # No matter what, scopes are intended to return ActiveRecord::Relation to make it chainable.
  # If you are expecting first, last or find results you should use class methods.

  # scope :get_previous_post, ->(current_id) { where("id < ?", current_id).last }
  # scope :get_previous_post_s_title, ->(current_id, search) { where("id < ? and title like ?", current_id, "%" + search.to_s + "%").last }
  # scope :get_previous_post_s_writer, ->(current_id, search) { where("id < ? and title like ?", current_id, "%" + search.to_s + "%").last }

end
