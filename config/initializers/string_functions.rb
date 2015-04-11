class String
	def ru_upper
		['А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я']
	end
	def ru_down
		['а','б','в','г','д','е','ё','ж','з','и','й','к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ','ъ','ы','ь','э','ю','я']
	end
	def my_length
			i = 0
			self.chars do |ch|
				i += 1
			end
			return i
	end
	def myIndex
		for i in 0..32
			return i if self == ru_upper[i] || self == ru_down[i]
		end
		return -1
	end
	def ru_downcase
		v = ''
		t = self.downcase
		t.chars do |ch|
			i = ch.myIndex
			if i >= 0
				v += ru_down[i]
			else
				v += ch
			end
		end
		return v
	end
	def ru_upcase
		v = ''
		t = self.upcase
		t.chars do |ch|
			i = ch.myIndex
			if i >= 0
				v += ru_upper[i]
			else
				v += ch
			end
		end
		return v
	end
end