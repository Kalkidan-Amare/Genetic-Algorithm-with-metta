;; Parameters
(= (POPULATION_SIZE) 10)
(= (INDIVIDUAL_LENGTH) 8)
(= (MAX_GENERATIONS) 10)
(= (CROSSOVER_POINT) 4)


;; Joins two lists (tuples) together.
(= (concatinate $list1 $list2)
  (if (== $list1 ())
    $list2
    (cons-atom (car-atom $list1) (concatinate (cdr-atom $list1) $list2))))

(= (map $list $function)
  (if (== $list ())
    ()
    (cons-atom ($function (car-atom $list)) (map (cdr-atom $list) $function))))

;; Takes a part of a list from a start index to an end index.
(= (sublist-recursive $list $start $end $index $accumulator)
  (if (or (== $list ()) (>= $index $end))
    $accumulator
    (let ($new-accumulator (if (>= $index $start)
                             (append-to-list $accumulator (car-atom $list))
                             $accumulator))
      (sublist-recursive (cdr-atom $list) $start $end (inc $index) $new-accumulator))))

;; function to start the sublist operation.
(= (sublist $list $start $end)
  (sublist-recursive $list $start $end 0 ()))

;; Sorts a list of (score . individual) pairs in descending order.
(= (insert-into-sorted $item $sorted-list)
  (if (== $sorted-list ())
    (cons-atom $item ())
    (if (> (car-atom $item) (car-atom (car-atom $sorted-list)))
      (cons-atom $item $sorted-list)
      (cons-atom (car-atom $sorted-list) (insert-into-sorted $item (cdr-atom $sorted-list))))))
(= (sort $list)
  (if (== $list ())
    ()
    (insert-into-sorted (car-atom $list) (sort (cdr-atom $list)))))



;; Creates one random individual
(= (create-individual-recursive $rng $length $accumulator)
  (if (== $length 0)
    $accumulator
    (create-individual-recursive $rng (dec $length) (append-to-list $accumulator (random-int $rng 0 1)))))

;; Creates the starting population using the accumulator pattern.
(= (create-population-recursive $rng $size $length $accumulator)
  (if (== $size 0)
    $accumulator
    (create-population-recursive $rng (dec $size) $length (append-to-list $accumulator (create-individual-recursive $rng $length ())))))

;; Calculates the fitness score.
(= (calculate-fitness $individual)
  (sum $individual))


;; Pairs `(fitness . individual)`.
(= (pair-with-fitness $individual)
  (cons-atom (calculate-fitness $individual) $individual))



;; Builds the next generation by creating count new children.
(= (build-next-generation $rng $parent1 $parent2 $count $accumulator)
  ;; Base Case: If count is 0, we have created enough children.
  (if (== $count 0)
    $accumulator
    ;; Recursive Step, create one new child and add it to the accumulator.
    (let ($child (concatinate (sublist $parent1 0 (CROSSOVER_POINT)) (sublist $parent2 (CROSSOVER_POINT) (INDIVIDUAL_LENGTH))))
      (build-next-generation $rng $parent1 $parent2 (dec $count) (append-to-list $accumulator $child)))))

;; Main generational loop
(= (genetic-programming $rng $current-generation $max-generations $population)
  (let (;; STEP 1: Evaluate the population by pairing each individual with its fitness score.
         ;; used my own my-map and passed it to pair-with-fitness function.
         $evaluated-population (map $population pair-with-fitness))
    (let (;; STEP 2: Sort the evaluated population to find the best.
           $sorted-evaluated-population (sort $evaluated-population))
      (let (;; Get the single best individual of this generation.
             $best-of-generation (car-atom $sorted-evaluated-population))
        ;; print progress for this generation.
        (let ((println! "--- Generation: " $current-generation))
          (let ((println! "Best of Gen: " $best-of-generation))

            ;; Base Cases, if we have run all generations or if we have found a perfect solution (fitness score of 8).
            (if (or (> $current-generation $max-generations) (== (car-atom $best-of-generation) (INDIVIDUAL_LENGTH)))
              ;; If we stop, return the final sorted population.
              $sorted-evaluated-population
              ;; else
              (let (;; PARENT SELECTION: Get the top two parents from the sorted list.
                     $parent1 (cdr-atom (car-atom $sorted-evaluated-population)))
                     $parent2 (cdr-atom (car-atom (cdr-atom $sorted-evaluated-population))))
                (let (;; Build the new population of children.
                       $next-generation (build-next-generation $rng $parent1 $parent2 (POPULATION_SIZE) ()))
                  ;; Call self to start the next generation.
                  (genetic-programming $rng (inc $current-generation) $max-generations $next-generation)))))))))



;; Execution

;; Create the initial population
!(bind! $initial-population (create-population-recursive &rng (POPULATION_SIZE) (INDIVIDUAL_LENGTH) ()))
!(println! "Initial Population: " $initial-population)

;; Starting the recursive Genetic Programming run.
!(bind! $final-sorted-population (genetic-programming &rng 1 (MAX_GENERATIONS) $initial-population))

!(println! "Final Best Individual: " (car-atom $final-sorted-population))