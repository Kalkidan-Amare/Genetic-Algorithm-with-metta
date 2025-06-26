; Parameters
(= (POPULATION_SIZE) 7)
(= (INDIVIDUAL_LENGTH) 8)
(= (MAX_GENERATIONS) 10)


; Joins two lists (tuples) together.
(= (concatinate $list1 $list2)
  (if (== $list1 ())
    $list2
    (cons-atom (car-atom $list1) (concatinate (cdr-atom $list1) $list2))))

(= (map $list $function)
  (if (== $list ())
    ()
    (cons-atom ($function (car-atom $list)) (map (cdr-atom $list) $function))))

; Takes a part of a list from a start index to an end index.
(= (sublist-recursive $list $start $end $index $accumulator)
  (if (or (== $list ()) (>= $index $end))
    $accumulator
    (let ($new-accumulator (if (>= $index $start)
                             (cons-atom $accumulator (car-atom $list))
                             $accumulator))
      (sublist-recursive (cdr-atom $list) $start $end (+ $index 1) $new-accumulator))))

; function to start the sublist operation.
(= (sublist $list $start $end)
  (sublist-recursive $list $start $end 0 ()))

; Sorts a list of (score . individual) pairs in descending order.
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



; Creates one random individual
(= (create-individual $length $accumulator)
  (if (== $length 0)
    $accumulator

   (let* (
    ( $rand (random-int &rng 0 2) )
    ( $len (- $length 1) )
    ( $newlist (cons-atom $rand $accumulator) )
   )
   
   (create-individual $len $newlist)))
   )

; Creates the starting population using the accumulator pattern.
(= (create-population $size $length_p $accumulator)
  (if (< $size 1)
    $accumulator

    (let* (
    ( $new_size (- $size 1) )
    ($ind_string  (create-individual $length_p ()))
    ($new_list (cons-atom  $ind_string $accumulator))
   )
    
    (create-population $new_size $length_p $new_list)
    )
)
    
)

; Calculates the fitness score.
(= (calculate-fitness $individual)
  (sum $individual))


; Pairs `(fitness . individual)`.
(= (pair-with-fitness $individual)
  (cons-atom (calculate-fitness $individual) $individual))



; Creates 7 children by iteratingthrough all possible crossover points from 1 to 7.
(= (build-next-generation $parent1 $parent2 $crossover-point $accumulator)
  ; Base Case: If the crossover point reaches the end of the individual's length (8),
  ; we have created all 7 children. Stop and return the accumulated list.
  (if (== $crossover-point (INDIVIDUAL_LENGTH))
    $accumulator
    ; Recursive Step: Create one new child using the current crossover point.
    (let ($child (concatinate (sublist $parent1 0 $crossover-point) (sublist $parent2 $crossover-point (INDIVIDUAL_LENGTH))))
      ; Child with the next crossover point.
      (build-next-generation $parent1 $parent2 (+ $crossover-point 1) (cons-atom $child $accumulator)))))

; Main generational loop
(= (genetic-programming $rng $current-generation $max-generations $population)
  (let (; STEP 1: Evaluate the population by pairing each individual with its fitness score.
         ; used map and passed it to pair-with-fitness function.
         $evaluated-population (map $population pair-with-fitness))
    (let (; STEP 2: Sort the evaluated population to find the best.
           $sorted-evaluated-population (sort $evaluated-population))
      (let (; Get the single best individual of this generation.
             $best-of-generation (car-atom $sorted-evaluated-population))
        ; print progress for this generation.
        (let ((println! "--- Generation: " $current-generation))
          (let ((println! "Best of Gen: " $best-of-generation))

            ; Base Cases, if we have run all generations or if we have found a perfect solution (fitness score of 8).
            (if (or (> $current-generation $max-generations) (== (car-atom $best-of-generation) (INDIVIDUAL_LENGTH)))
              ; If we stop, return the final sorted population.
              $sorted-evaluated-population
              ; else
              (let (; PARENT SELECTION: Get the top two parents from the sorted list.
                     $parent1 (cdr-atom (car-atom $sorted-evaluated-population)))
                     $parent2 (cdr-atom (car-atom (cdr-atom $sorted-evaluated-population))))
                (let (; Build the new population of children.
                       $next-generation (build-next-generation $parent1 $parent2 1 ()))
                  ; Call self to start the next generation.
                  (genetic-programming $rng (inc $current-generation) $max-generations $next-generation)))))))))



; Execution

; Create the initial population
!(bind! &initial-population (create-population (POPULATION_SIZE) (INDIVIDUAL_LENGTH) ()))
!(println! "Initial Population: " &initial-population)
; Starting the recursive Genetic Programming run.
!(bind! &final-sorted-population (genetic-programming &rng 1 (MAX_GENERATIONS) $initial-population))

!(println! "Final Best Individual: " (car-atom &final-sorted-population))














!(create-population (POPULATION_SIZE) (INDIVIDUAL_LENGTH) ())
!(create-individual 8 ())

