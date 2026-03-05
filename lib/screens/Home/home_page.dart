import 'dart:convert';
import 'package:flutter/material.dart';
import 'colors.dart' as color;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> info = [];
  bool loading = true;

  Future<void> _initData() async {
    try {
      final data =
          await DefaultAssetBundle.of(context).loadString("assets/json/info.json");
      final decoded = json.decode(data);

      if (decoded is List) {
        final list = decoded.cast<Map<String, dynamic>>();
        if (!mounted) return;
        setState(() {
          info = list;
          loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          info = [];
          loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        info = [];
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  int _gridColumns(double w) {
    if (w >= 1200) return 4;
    if (w >= 800) return 3;
    return 2;
  }

  double _gridAspect(double w) {
    if (w >= 1200) return 1.25;
    if (w >= 800) return 1.15;
    return 1.05;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: color.AppColor.homePageBackground,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 70, left: 30, right: 30, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Text(
                    "Training",
                    style: TextStyle(
                      fontSize: 30,
                      color: color.AppColor.homePageTitle,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Icon(Icons.arrow_back_ios, size: 20, color: color.AppColor.homePageIcons),
                  const SizedBox(width: 10),
                  Icon(Icons.calendar_today_outlined, size: 20, color: color.AppColor.homePageIcons),
                  const SizedBox(width: 15),
                  Icon(Icons.arrow_forward_ios, size: 20, color: color.AppColor.homePageIcons),
                ],
              ),

              const SizedBox(height: 20),


              Row(
                children: [
                  Text(
                    "Training",
                    style: TextStyle(
                      fontSize: 18,
                      color: color.AppColor.homePageSubtitle,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 16,
                      color: color.AppColor.homePageDetail,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 18, color: color.AppColor.homePageIcons),
                ],
              ),

              const SizedBox(height: 20),

    
              Container(
                width: w,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.AppColor.gradientFirst.withOpacity(0.8),
                      color.AppColor.gradientSecond.withOpacity(0.9),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(80),
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(5, 10),
                      blurRadius: 20,
                      color: color.AppColor.gradientSecond.withOpacity(0.25),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 25, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Next workout",
                        style: TextStyle(
                          fontSize: 16,
                          color: color.AppColor.homePageContainerTextSmall,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Chest workout",
                        style: TextStyle(
                          fontSize: 25,
                          color: color.AppColor.homePageContainerTextSmall,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Triceps & shoulders",
                        style: TextStyle(
                          fontSize: 25,
                          color: color.AppColor.homePageContainerTextSmall,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.timer, size: 20, color: color.AppColor.homePageContainerTextSmall),
                              const SizedBox(width: 10),
                              Text(
                                "60 min",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: color.AppColor.homePageContainerTextSmall,
                                ),
                              ),
                            ],
                          ),
                          const Expanded(child: SizedBox()),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: color.AppColor.gradientFirst.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(4, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

             
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/template.png"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      color: color.AppColor.gradientSecond.withOpacity(0.12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/correndo.png",
                        height: 130,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "You are doing great",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: color.AppColor.homePageDetail,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "keep it up",
                              style: TextStyle(
                                fontSize: 14,
                                color: color.AppColor.homePagePlanColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "stick to your plan",
                              style: TextStyle(
                                fontSize: 14,
                                color: color.AppColor.homePagePlanColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

    
              Text(
                "Area of focus",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: color.AppColor.homePageTitle,
                ),
              ),

              const SizedBox(height: 15),

              loading
                  ? const Center(child: CircularProgressIndicator())
                  : info.isEmpty
                      ? const Center(child: Text("Sem itens no info.json"))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: info.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridColumns(w),
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: _gridAspect(w),
                          ),
                          itemBuilder: (_, i) {
                            final item = info[i];
                            final title = item["title"]?.toString() ?? "";
                            final img = item["img"]?.toString() ?? "";

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                    color: color.AppColor.gradientSecond.withOpacity(0.12),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: img.isEmpty
                                        ? const Icon(Icons.image_not_supported, size: 60)
                                        : Image.asset(
                                            img,
                                            fit: BoxFit.contain,
                                            color: color.AppColor.gradientSecond,
                                          ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: color.AppColor.homePageDetail,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}