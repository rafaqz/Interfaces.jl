expected_extended_help = """# Extended help

## Mandatory keys:

* `neutral_check`:
  * neutral stable
* `multiplication_check`:
  * multiplication stable
* `inversion_check`:
  * inversion stable
  * inversion works"""

@test strip(Interfaces._extended_help(Group.GroupInterface)) == strip(expected_extended_help)


expected_docs = """```
    GroupInterface
```

An Interfaces.jl `Interface` with mandatory components `(:neutral_check, :multiplication_check, :inversion_check)` and optional components `()`.

A group is a set of elements with a neutral element where you can perform multiplications and inversions.

The conditions checking the interface accept an `Arguments` object with two fields named `x` and `y`. The type of the first field `x` must be the type you wish to declare as implementing `GroupInterface`.

# Extended help

## Mandatory keys:

  * `neutral_check`:

      * neutral stable
  * `multiplication_check`:

      * multiplication stable
  * `inversion_check`:

      * inversion stable
      * inversion works"""

@test strip(string(@doc Group.GroupInterface)) == strip(expected_docs)

