module.exports = ({ model }, BaseSchema) => {
  const modelName = 'Product';

  const ProductSchema = new BaseSchema({
    name: {
      type: String,
      required: true,
    },
  });

  return model(modelName, ProductSchema);
};
