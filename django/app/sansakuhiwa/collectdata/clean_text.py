# -*- coding: utf-8 -*-
import locationfromazure
import re

class LocationCleaner:
    def __init__(self, name_list):
        self.name_list = name_list
        self.cleaned_name_list = []
        self.removed_elements = []

    def clean_location_names(self):
        for name in self.name_list:
            if re.search(r'(国|県|都|府|区|市)', name):
                self.removed_elements.append(name)
            else:
                self.cleaned_name_list.append(name)

"""if __name__ == '__main__':
    # 使用例
    name_list = locationfromazure.name_list
    cleaner = LocationCleaner(name_list)
    cleaner.clean_location_names()

    # 地名のリストを参照する
    cleaned_names = cleaner.cleaned_name_list
    print("地名のリスト:")
    print(cleaned_names)
    removed_names = cleaner.removed_elements
    print("削除されたリスト")
    print(removed_names)"""