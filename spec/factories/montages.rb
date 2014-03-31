# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :montage do
    source_id 1
    crop_x 1
    crop_y 1
    crop_width 1
    crop_height 1
    image "MyString"
  end
end
