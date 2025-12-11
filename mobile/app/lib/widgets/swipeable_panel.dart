import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class SwipeablePanel extends StatefulWidget {
  final List<Widget> pages;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const SwipeablePanel({
    super.key,
    required this.pages,
    this.borderRadius = 25,
    this.padding,
  });

  @override
  State<SwipeablePanel> createState() => _SwipeablePanelState();
}

class _SwipeablePanelState extends State<SwipeablePanel> {
  late final PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: PageView(
                controller: _controller,
                children: widget.pages,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        SmoothPageIndicator(
          controller: _controller,
          count: widget.pages.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: Colors.white,
            dotColor: Colors.white38,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 6,
          ),
        ),
      ],
    );
  }
}
