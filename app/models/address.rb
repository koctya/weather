class Address < ApplicationRecord
    validates :street, presence: true
    validates :city, presence: true
    validates :zip, presence: true

    def to_s()
        "#{street}, #{city}, #{zip}"
    end
end
