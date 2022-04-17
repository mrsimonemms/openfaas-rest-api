module.exports = ({ model }, BaseSchema) => {
  const modelName = 'ProductSize';

  const ProductSizeSchema = new BaseSchema({
    productId: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
  });

  return model(modelName, ProductSizeSchema);
};
