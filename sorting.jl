# Reference: Cormen, p. 18
# Notes: I ran into the problem of Julia's parametric typing system, because I
# wanted the algorithm to work on any array of real numbers. This meant I wanted
# concrete subtypes of Int and AbstractFloat to work correctly. Naively, I wrote
# the function signature:
#    insertionsort(A::Array{Real, 1})
# but this fails because, for example,
#    Array{Int64, 1} <: Array{Real, 1} => false
# I think that this is due to compiler optimization, if I remember the lecture I
# watched correctly. Regardless, for parametric type abstraction for methods,
# the correct syntax is given below:
function insertionsort{T<:Real}(A::Array{T,1})
    for j = 2:length(A)
        key = A[j]
        # Insert A[j] into the sorted sequence A[1..j-1].
        i = j - 1
        while i > 0 && A[i] > key
            A[i+1] = A[i]
            i -= 1
        end
        A[i+1] = key
    end
end

# Reference: Cormen, p. 34
function mergesort{T<:Real}(A::Array{T,1})
    # Reference: Cormen, p. 31
    # This was more straightforward to implement, but I developed a bit of a
    # "hacked" solution for introducing the sentinel '∞' that is used in the
    # textbook. I essentially set ∞ to the maximum allowable value for the
    # specified type, so it acts like infinity for every practical purpose.
    function merge{T<:Real}(A::Array{T,1}, p::Int, q::Int, r::Int)
        ∞ = typemax(T) - 1
        n₁, n₂ = q - p + 1, r - q
        L, R = zeros(T,n₁+1), zeros(T, n₂+1)
        L[1:end-1] = A[p:p+n₁-1]
        R[1:end-1] = A[q+1:q+n₂]
        L[n₁+1], R[n₂+1] = ∞, ∞
        i, j = 1, 1
        for k = p:r
            if L[i] <= R[j]
                A[k] = L[i]
                i += 1
            else
                A[k] = R[j]
                j += 1
            end
        end
    end


    function kernel{T<:Real}(A::Array{T,1}, p::Int, r::Int)
        if p < r
            q = Int(floor((p + r) / 2))
            kernel(A, p, q)
            kernel(A, q + 1, r)
            merge(A, p, q, r)
        end
    end

    kernel(A, 1, length(A))
end

# Reference: Cormen, p. 161
function heapsort{T<:Real}(A::Array{T,1})
    # Reference: Cormen, p. 152
    parent(i::Int) = Int(floor(i/2))
    leftchild(i::Int) = 2i
    rightchild(i::Int) = 2i + 1

    # Reference: Cormen, p. 154
    # The modification from the book is that maxheapify also takes an additional
    # parameter, 'size', which gives the size of the heap.
    function maxheapify{T<:Real}(A::Array{T,1}, i::Int, size::Int)
        # get the children of i
        l, r = leftchild(i), rightchild(i)

        # check if the left child exists and is greater than i
        if l <= size && A[l] > A[i]
            largest = l
        else
            largest = i
        end

        # check if the right child exists and is greater than i
        if r <= size && A[r] > A[largest]
            largest = r
        end

        # if one of the children is greater than the node A[i], swap them and
        # recurse
        if largest != i
            A[i], A[largest] = A[largest], A[i]
            maxheapify(A, largest, size)
        end
    end

    # Reference: Cormen, p. 157
    # The modification made here is that the heap size is calculated and
    # returned instead of being made an attribute of A. This is to avoid making
    # new types.
    function buildmaxheap{T<:Real}(A::Array{T, 1})
        size = length(A)
        for i = Int(floor(length(A)/2)):-1:1
            maxheapify(A, i, size) end
        size
    end

    # The actual heap sort is down here:
    size = buildmaxheap(A)
    for i = length(A):-1:2
        A[1], A[i] = A[i], A[1]
        size -= 1
        maxheapify(A, 1, size)
    end
end

function quicksort{T<:Real}(A::Array{T,1})

    # Reference: Cormen, p. 171
    function partition{T<:Real}(A::Array{T,1}, p::Int, r::Int)
        x = A[r]
        i = p - 1
        for j = p:-1:(r-1)
            if A[j] <= x
                i += 1
                A[i], A[j] = A[j], A[i]
            end
        end
        A[i+1], A[r] = A[r], A[i+1]

        i + 1
    end

    # Reference: Cormen, p. 179
    function randomizedpartition{T<:Real}(A::Array{T,1}, p::Int, r::Int)
        i = rand(p:r)
        A[r], A[i] = A[i], A[r]
        partition(A, p, r)
    end

    # Reference: Cormen, p. 171
    function kernel{T<:Real}(A::Array{T,1}, p::Int, r::Int)
        if p < r
            q = randomizedpartition(A, p, r)
            kernel(A, p, q - 1)
            kernel(A, q + 1, r)
        end
    end

    kernel(A, 1, length(A))
end

function countingsort{T<:Real}(A::Array{T,1}, B::Array{T,1}, k::Int)
    C = zeros(k+1)
    for j = 1:length(A)
        C[A[j]] += 1
    end
    for i = 2:(k+1)
        C[i] = C[i] + C[i-1]
    end
    for j = length(A):-1:1
        B[C[A[j]]] = A[j]
        C[A[j]] = C[A[j]] - 1
    end
end
