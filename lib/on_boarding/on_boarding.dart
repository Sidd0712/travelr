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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          const SizedBox(height: 16),
          Text(
            "travelr",
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ]),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
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
                style: ButtonStyle(
                  fixedSize: const WidgetStatePropertyAll(
                    Size(double.infinity, 48),
                  ),
                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                ),
                child: Center(
                  child: Text(
                    currentIndex == slides.length - 1 ? "Get Started" : "Next",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
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
    final colorScheme = Theme.of(context).colorScheme;

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
          color: currentIndex == index
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
