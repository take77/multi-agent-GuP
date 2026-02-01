# Users
user1 = User.find_or_create_by!(email: "miho@oarai.ac.jp") do |u|
  u.name = "西住みほ"
end

user2 = User.find_or_create_by!(email: "yukari@oarai.ac.jp") do |u|
  u.name = "秋山優花里"
end

# Novels
novel1 = Novel.find_or_create_by!(title: "戦車道の心得", user: user1) do |n|
  n.synopsis = "戦車道を通じて成長する少女たちの物語"
  n.genre = :literary
  n.status = :published
  n.published_at = Time.zone.now
  n.total_episodes = 3
end

novel2 = Novel.find_or_create_by!(title: "秘密の戦車図鑑", user: user2) do |n|
  n.synopsis = "世界中の戦車を巡る冒険記"
  n.genre = :fantasy
  n.status = :draft
end

# Chapters
chapter1 = Chapter.find_or_create_by!(novel: novel1, chapter_number: 1) do |c|
  c.title = "出会い"
  c.synopsis = "大洗女子学園に転校してきた日"
end

chapter2 = Chapter.find_or_create_by!(novel: novel1, chapter_number: 2) do |c|
  c.title = "初陣"
  c.synopsis = "初めての練習試合"
end

# Episodes
Episode.find_or_create_by!(novel: novel1, chapter: chapter1, episode_number: 1) do |e|
  e.title = "転校初日"
  e.body = "春の陽射しが差し込む校門をくぐった。新しい学園生活の始まりだ。"
  e.word_count = 24
  e.status = :published
  e.published_at = Time.zone.now
end

Episode.find_or_create_by!(novel: novel1, chapter: chapter1, episode_number: 2) do |e|
  e.title = "戦車道との再会"
  e.body = "選択授業の一覧に「戦車道」の文字を見つけた瞬間、胸が高鳴った。"
  e.word_count = 28
  e.status = :published
  e.published_at = Time.zone.now
end

Episode.find_or_create_by!(novel: novel1, chapter: chapter2, episode_number: 3) do |e|
  e.title = "IV号戦車、発進"
  e.body = "エンジンの轟音が格納庫に響き渡る。いよいよ初陣だ。"
  e.word_count = 22
  e.status = :draft
end

puts "Seed data created successfully."
