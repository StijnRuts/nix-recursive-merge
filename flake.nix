{
  inputs.nixtest.url = "github:jetify-com/nixtest";
  outputs =
    { self, nixtest }:
    {
      tests = nixtest.run ./.;
    };
}
