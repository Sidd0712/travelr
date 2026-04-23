import 'package:flutter/material.dart';
import 'package:travelr/home/main_fragment.dart';
import 'package:travelr/on_boarding/slider_widget.dart';
import 'package:travelr/on_boarding/slidermodel.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  final List<SliderModel> slides = getSlides();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(children: [
          SizedBox(
            height: 20,
          ),
          Text(
            "travelr",
            style: TextStyle(
                fontFamily: "Northlane", fontSize: 38, color: Colors.black),
          ),
        ]),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemBuilder: (context, index) {
                  return SliderWidget(
                    image: slides[index].image,
                    title: slides[index].title,
                    description: slides[index].description,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => buildDot(index),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextButton(
                onPressed: () {
                  if (currentIndex == slides.length - 1) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const HomeScreen(parent: "Sign-Up")));
                  } else {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                },
                style: const ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                child: Center(
                  child: Text(
                    currentIndex == slides.length - 1 ? "Get Started" : "Next",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return GestureDetector(
      onTap: () => {
        _controller.animateToPage(index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut),
        setState(() => currentIndex = index)
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 10,
        width: currentIndex == index ? 25 : 10,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: currentIndex == index ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
