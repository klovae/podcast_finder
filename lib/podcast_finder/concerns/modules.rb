class PodcastFinder::CreateAndRead
  module InstanceMethods
    def save
      self.class.all << self
    end
  end

  module ClassMethods

    def find_by_name(name)
      self.all.detect {|item| item.name == name}
    end

    def find_or_create_by_name(name, hash)
      if find_by_name(name).nil?
        self.new(hash)
      else
        find_by_name(name)
      end
    end
  end
end
