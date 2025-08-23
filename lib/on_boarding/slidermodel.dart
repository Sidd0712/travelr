class SliderModel {
  final String image;
  final String title;
  final String description;

  SliderModel(
      {required this.image, required this.title, required this.description});
}

List<SliderModel> getSlides() {
  return [
    SliderModel(
      image: "assets/images/slider1.jpg",
      title: "Title 1",
      description: "This is the first description. For no reason obviously.",
    ),
    SliderModel(
      image: "assets/images/slider2.png",
      title: "Title 2",
      description:
          "This is the second description. Again, for no reason obviously.",
    ),
    SliderModel(
      image: "assets/images/slider3.jpeg",
      title: "Title 2",
      description:
          "This is the third description. Definitely for no reason again lol.",
    ),
  ];
}
