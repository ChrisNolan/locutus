# a dictionary/hash of movie creitics and their ratings of a small set of movies
@critics = {
  'Lisa Rose' => {
    'Lady in the Water' => 2.5,
    'Snakes on a Plane' => 3.5,
    'Just My Luck' => 3.0,
    'Superman Returns' => 3.5,
    'You, Me and Dupree' => 2.5,
    'The Night Listener' => 3.0
  },
  'Gene Seymour' => {
    'Lady in the Water' => 3.0,
    'Snakes on a Plane' => 3.5,
    'Just My Luck' => 1.5,
    'Superman Returns' => 5.0,
    'The Night Listener' => 3.0,
    'You, Me and Dupree' => 3.5
  },
  'Michael Phillips' => {
    'Lady in the Water' => 2.5,
    'Snakes on a Plane' => 3.0,
    'Superman Returns' => 3.5,
    'The Night Listener' => 4.0
  },
  'Claudia Puig' => {
    'Snakes on a Plane' => 3.5,
    'Just My Luck' => 3.0,
    'The Night Listener' => 4.5,
    'Superman Returns' => 4.0,
    'You, Me and Dupree' => 2.5
  },
  'Mick LaSalle' => {
    'Lady in the Water' => 3.0,
    'Snakes on a Plane' => 4.0,
    'Just My Luck' => 2.0,
    'Superman Returns' => 3.0,
    'The Night Listener' => 3.0,
    'You, Me and Dupree' => 2.0
  },
  'Jack Matthews' => {
    'Lady in the Water' => 3.0,
    'Snakes on a Plane' => 4.0,
    'The Night Listener' => 3.0,
    'Superman Returns' => 5.0,
    'You, Me and Dupree' => 3.5
  },
  'Toby' => {
    'Snakes on a Plane' => 4.5,
    'You, Me and Dupree' => 1.0,
    'Superman Returns' => 4.0
  },
  'Chris Nolan.ca' => {
    'Lady in the Water' => 3.5,
    'Snakes on a Plane' => 0.01, # Hmmm... if I comment out this recommendation, then Toby & I are a 1.0 match.  is that a good thing?  We just have 2 shared items then but they aren't equal... look into later I guess
    'Superman Returns' => 4.0,
    'You, Me and Dupree' => 3.75
  }
}

# page 10 -- simple Euclidean Distance
Math.sqrt((5-4)**2 + (4-1)**2)

# inversed
1/(1+Math.sqrt((5-4)**2 + (4-1)**2))

(2.5 - 3.0)**2
(3.5 - 3.5)**2
(3.0 - 1.5)**2
(3.5 - 5.0)**2
(2.5 - 3.5)**2
(3.0 - 3.0)**2

# all that above crud to decide my function was correct and teh book was wrong.
# I've submitted an errata, but the result should be 0.294298055085549 (1/(1+Math.sqrt(5.75))) and not 0.148148148148148 (1/(1+5.75))

# Returns a distance-based similarity score for person1 and person2
def simularity_distance(preferences, person1, person2)
  # Get the list of shared_items
  shared_items = {}
  for item in preferences[person1].keys
    shared_items[item] = 1 if preferences[person2].keys.include? item
  end
  
  # nothing in common
  return 0 if shared_items.empty?
  
  # Add up the squares of all the differences
  sum_of_squares = shared_items.keys.inject(0.0) {|sum, item|
    sum + (preferences[person1][item] - preferences[person2][item])**2
  }
  return 1/(1 + Math.sqrt(sum_of_squares))
end

print "SimularityDistance: "
puts simularity_distance(@critics, 'Lisa Rose', 'Gene Seymour')

# Pearson Correlation from page 13
def simularity_pearson(preferences, person1, person2)
  # Get the list of shared_items
  shared_items = {}
  for item in preferences[person1].keys
    shared_items[item] = 1 if preferences[person2].keys.include? item
  end
  
  # nothing in common
  return 0 if shared_items.empty?
  
  # Add up all the preferences
  sum1 = shared_items.keys.inject(0) {|sum, item| sum + preferences[person1][item]}
  sum2 = shared_items.keys.inject(0) {|sum, item| sum + preferences[person2][item]}
  
  # Sum up the squares
  sum1_squared = shared_items.keys.inject(0) {|sum, item| sum + preferences[person1][item]**2}
  sum2_squared = shared_items.keys.inject(0) {|sum, item| sum + preferences[person2][item]**2}
  
  # Sum up the productions
  product_sum = shared_items.keys.inject(0) {|sum, item| sum + preferences[person1][item] * preferences[person2][item]}
  
  # Calculate Pearson score
  num = product_sum - (sum1*sum2/shared_items.length)
  den = Math.sqrt((sum1_squared - sum1**2/shared_items.length) * (sum2_squared - sum2**2/shared_items.length))
  den.zero? ? 0 : num/den
end

print 'SimularityPearson: '
puts simularity_pearson(@critics, 'Lisa Rose', 'Gene Seymour')

# # pseudocode for Pearson Correlation from wikipedia
# uses a bit easier to follow variable names than the above example
# http://en.wikipedia.org/wiki/Correlation#Computing_correlation_accurately_in_a_single_pass
#  sum_sq_x = 0
#  sum_sq_y = 0
#  sum_coproduct = 0
#  mean_x = x[1]
#  mean_y = y[1]
#  for i in 2 to N:
#      sweep = (i - 1.0) / i
#      delta_x = x[i] - mean_x
#      delta_y = y[i] - mean_y
#      sum_sq_x += delta_x * delta_x * sweep
#      sum_sq_y += delta_y * delta_y * sweep
#      sum_coproduct += delta_x * delta_y * sweep
#      mean_x += delta_x / i
#      mean_y += delta_y / i 
#  pop_sd_x = sqrt( sum_sq_x / N )
#  pop_sd_y = sqrt( sum_sq_y / N )
#  cov_x_y = sum_coproduct / N
#  correlation = cov_x_y / (pop_sd_x * pop_sd_y)

# See other Metric functions @ http://en.wikipedia.org/wiki/Metric_(mathematics)

# Ranking the Critics -- page 14

# Returns the best matches for person from the preferences
# Number of results and similariy funcation are optional params
def top_matches(preferences, person, n=5, similarity=:simularity_pearson)
  scores = preferences.keys.collect {|other_person|
    [send(similarity, preferences, person, other_person), other_person] unless person == other_person
  }.compact.sort.reverse[0...n]
end

puts 'TopMatches: '
puts "\tToby:\t\t#{top_matches(@critics, 'Toby', 3).inspect}"
puts "\tChris Nolan.ca:\t#{top_matches(@critics, 'Chris Nolan.ca', 3).inspect}" # Note here I get some negatives too -- that means we're dis-similar