#! usr/local/ruby

POPULATION_SIZE = 1000
POOL_SIZE = Integer( POPULATION_SIZE * 0.3 ) # pool is 5% of population
RAND = Random.new
DICTIONARY = ('a'..'z').to_a << ' '

def ga( target = 'hello' )
  population = initialise_population target

  pool = pop_fit = []
  # Compute fitness values
  pop_fit = eval_population population, target

  while !done? pop_fit
    pool, pop_fit = select_pool pop_fit
    pool = crossover pool, target
    pool = mutate pool, target
    pop_fit = merge pool, pop_fit
  end
end

def initialise_population( target )
  population = Array.new( POPULATION_SIZE ) do |i|
    DICTIONARY.sample( target.length ).join
  end

  population
end

def eval_population( population, target )
  population.map do |candidate|
    [candidate, fitness( candidate, target )]
  end
end
#p = initialise_population( 'hello world' )
#p = eval_population( p, 'hello world' )

# We're just doing a simple Euclidean distance per character
# from the target string
# RETURNS an array of tuples of the form
#   [ candidate, fitness_value ]
def fitness( candidate, target )
  total = 0

  i = 0
  candidate.each_byte do |char_num|
    abs_distance = ( target[i].ord - char_num ).abs
    total += abs_distance
    i += 1
  end

  total
end
#fitness( 'hello world', 'hello world' )
#fitness( 'gello world', 'hello world' )

# INPUT population is an array of value-fitness tuples
def select_pool( population )
  raise "Something's wrong with population!" unless population.size == POPULATION_SIZE

  sorted_population = population.sort_by! { |v| v[1] }

  pool = sorted_population[0...POOL_SIZE]
  pop = sorted_population[POOL_SIZE..(population.size)]
  #puts "POOL #{pool.size} POP #{pop.size}"

  raise "Wrong splitting!" unless pool.size + pop.size == population.size

  puts pool[0].join(' ')

  return pool, pop
end
#pool, pop = select_pool( p )

def crossover( pool, target )
  crossed_pool = Array.new

  # p1, p2 - parents
  # c1, c2 - children
  pool.each do |p1, fitness|
    if RAND.rand <= 0.7 # 80% chance
      # Find the second parent to crossover with
      p2 = nil
      begin
        p2 = pool.sample[0]
      end while p2 == p1 or p2.nil?

      c1, c2 = cross( p1, p2 )

      # HACK
      crossed_pool << [c1, fitness(c1, target)] if crossed_pool.size < pool.size
      crossed_pool << [c2, fitness(c2, target)] if crossed_pool.size < pool.size
    else
      crossed_pool << [p1, fitness] if crossed_pool.size < pool.size
    end
  end

  crossed_pool
end
#crossover(pop, 'hello world')

def cross( p1, p2 )
  length = p1.length
  offset = RAND.rand( 1...length )
  c1 = p1[0...offset] + p2[offset...length]
  c2 = p2[0...offset] + p1[offset...length]

  return c1, c2
end

def mutate( pool, target )
  mutated_pool = Array.new

  pool.each do |c, fitness|
    mut_c = String.new c

    if RAND.rand <= 0.05 # 5% chance
      mutation_pos = RAND.rand(0...(c.length))
      mut_c[mutation_pos] = DICTIONARY.sample
    end

    mutated_pool << [mut_c, fitness(mut_c, target)]
  end

  if pool.size != POOL_SIZE or mutated_pool.size != POOL_SIZE or mutated_pool.size == 0
    raise "Mutation failure! Pool size is #{pool.size}"
  end

  pool
end
#mutate pop

def merge( pool, population )
  (pool + population).shuffle
end

def done?( population )
  matching = population.select {|c, fitness| fitness == 0}
  if matching.size != 0
    puts "#{matching[0][0]} <--- SUCCESS!"
    true
  else
    false
  end
end

ga 'hello'
