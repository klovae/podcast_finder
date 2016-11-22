module CreateAndRead
  module InstanceMethods
    def save
      @@all << self
    end
  end

  module ClassMethods
    def all
      @@all
    end

    def find_by_name(name)
      self.all.detect {|item| item.name == name}
    end

    def find_or_create_by_name(hash)
      if find_by_name(hash[:name]).nil?
        self.new(hash)
      else
        find_by_name(hash[:name])
      end
    end
  end
end
