using StatsBase
function obj(x)
   sum([i^2 for i in x]) 
end

 #F is scale factor
function mutation(x, F)
   x[1] + F * (x[2] - x[3]) 
end

function check_bounds(mutated, bounds)
   [clamp(mutated[i], bounds[i,0], bounds[i,1]) for i in 1:length(bounds)]
end

 # cr is crossover rate
function crossover(mutated, target, dims, cr)
 #@show mutated
 #  @show target
 #  @show dims
   #generate a uniform random value for every dimension
   p = rand(dims)
 #  println("p = $p")
 #trial = [mutated[i] if p[i] < cr else target[i] for i in 1:dims ]
   trial = [(p[i] < cr) ? mutated[i] : target[i] for i in 1:dims ]
   return trial
end

function differential_evolution(pop_size, bounds, iter, F, cr)
   pop = Array((bounds[:, 1] .+ (rand(size(bounds)[1], pop_size)) .* (bounds[:, 2] - bounds[:,1]))')
   obj_all = [obj(ind) for ind in pop]
   best_vector = pop[argmin(obj_all)[1],:]
   best_obj = minimum(obj_all)
   prev_obj = best_obj
   obj_iter = []
   for i in 1:iter
      for j in 1:pop_size
         candidates = [candidate for candidate in 1:pop_size if candidate != j]
         aa = pop[sample(candidates, 3, replace=false), :]
         #kludgey this
         a = aa[1,:]     
         b = aa[2,:]     
         c = aa[3,:]     
         mutated = mutation([a,b,c], F)
         # perform crossover
         trial = crossover(mutated, pop[j,:], size(bounds)[1], cr)
         obj_target = obj(pop[j])
         obj_trial  = obj(trial)
         if obj_trial < obj_target
            pop[j,:] = trial
            obj_all[j] = obj_trial
         end
      end
      best_obj = minimum(obj_all)
      if best_obj < prev_obj
        best_vector = pop[argmin(obj_all)[1], :]
        prev_obj = best_obj
        append!(obj_iter, best_obj)
        println("Iteration: $i f( $best_vector ) = $best_obj")
      end
   end   
   [best_vector, best_obj, obj_iter]
end


pop_size = 10
bounds = [ -5.0 5.0
           -5.0 5.0
         ]
iter = 200
F    = 0.5
cr   = 0.7

solution = differential_evolution(pop_size, bounds, iter, F, cr)
println("\nSolution: f([$solution[1]]) = $solution[2]")

using Plots
plot(solution[3])
