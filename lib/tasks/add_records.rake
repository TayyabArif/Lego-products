# lib/tasks/import_csv.rake
require 'csv'

task :add_records => :environment do
  csv_path = Rails.root.join('lib', 'csv', 'sets.csv')

  CSV.foreach(csv_path, headers: true) do |row|
    product = Product.new
    product.name = row['name'] # Replace 'attribute1' with the actual column name in the CSV file
    product.set_num = row['set_num'] # Replace 'attribute2' with the actual column name in the CSV file
    product.theme_id = row['theme_id'] # Replace 'attribute2' with the actual column name in the CSV file
    product.num_parts = row['num_parts'] # Replace 'attribute2' with the actual column name in the CSV file
    product.year = row['year'] # Replace 'attribute2' with the actual column name in the CSV file
    product.img_url = row['img_url'] # Replace 'attribute2' with the actual column name in the CSV file

    # Assign other attributes similarly

    product.save!
  end
end
