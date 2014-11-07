class User < ActiveRecord::Base
  has_many :posts
  has_one :profile

  has_many :relationships,
    class_name: "Follower",
    foreign_key: :leader_id

  has_many :reverse_relationships,
    class_name: "Follower",
    foreign_key: :follower_id

  has_many :followers, through: :relationships, source: :follower
  has_many :leaders, through: :reverse_relationships, source: :leader
end

class Post < ActiveRecord::Base
  belongs_to :user
end

class Profile < ActiveRecord::Base
  belongs_to :user
end

class Follower < ActiveRecord::Base
  belongs_to :follower,
    class_name: "User",
    foreign_key: :follower_id
  belongs_to :leader,
    class_name: "User",
    foreign_key: :leader_id
end