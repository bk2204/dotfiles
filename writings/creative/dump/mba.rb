#!/usr/bin/ruby

request = ARGV[0]
category = ARGV[1]

def get_text(cat)
	n = ['bicycling', 'culture', 'life', 'meta', 'writings', 'announcements']
	h = {
		'memes'=>'Memes and Humor',
		'life/personal'=>'Personal Life',
		'life/volunteer'=>'Life as a Volunteer',
		'life/rants'=>'Rants about Life',
		'tech'=>'Technology',
		'tech/rants'=>'Rants about Technology',
		'tech/sysadmin'=>'System Administration',
		'tech/ideas'=>'Technology Ideas',
		'opinions'=>'Opinion',
		'thoughts'=>'Thoughts and Reflections',
		'culture/language'=>'Language',
		'culture/politics'=>'Politics',
		'culture/entertainment'=>'Entertainment',
		'culture/rants'=>'Rants about Culture',
		'culture/ideas'=>'Cultural Ideas'
	}
	n.each { |x|
		h[x] = x.capitalize
	}
	return h[cat]
end

result = nil
if request == '-t':
	result = get_text(category)
end
exit 2 if result.nil?
puts result
exit 0

