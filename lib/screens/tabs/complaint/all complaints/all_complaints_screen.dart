import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'across_india_complaints.dart';
import 'my_city_complaints.dart';

class AllComplaintsScreen extends StatelessWidget {
  const AllComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: const Text(
            'All Complaints',
            style: TextStyle(fontSize: 18),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50), // Adjust height
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    labelColor: Colors.deepPurpleAccent,
                    indicatorColor: Colors.deepPurpleAccent,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: 'My City'),
                      Tab(text: 'Across India'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Filter Options',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CheckboxListTile(
                                value: false,
                                title: const Row(
                                  children: [
                                    Icon(CupertinoIcons.calendar_today),
                                    SizedBox(width: 8),
                                    Text('Latest'),
                                  ],
                                ),
                                onChanged: (_) {},
                              ),
                              CheckboxListTile(
                                value: false,
                                title: const Row(
                                  children: [
                                    Icon(Icons.arrow_circle_up_rounded),
                                    SizedBox(width: 8),
                                    Text('Most upvoted'),
                                  ],
                                ),
                                onChanged: (_) {},
                              ),
                              CheckboxListTile(
                                value: false,
                                title: const Row(
                                  children: [
                                    Icon(Icons.bar_chart_rounded),
                                    SizedBox(width: 8),
                                    Text('Most viewed'),
                                  ],
                                ),
                                onChanged: (_) {},
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  tooltip: 'Filter',
                  icon: const Icon(CupertinoIcons.slider_horizontal_3),
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            MyCityComplaints(),
            AcrossIndiaComplaints(),
          ],
        ),
      ),
    );
  }
}
