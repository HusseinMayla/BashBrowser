#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/parser.sh"

sample_html='<div data-region="paged-content-page" data-page="1" class="" id="yui_3_17_2_1_1786898538384_162">
        <div role="list" id="yui_3_17_2_1_1786898538384_161">
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9231">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9231" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>

            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9231" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">Advanced prog- A - Spring 25 [26] - war</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9391">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9391" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>

            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9391" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">Application Development - A</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
</div>'

echo "=== PARSED ELEMENTS ==="
parse_page "$sample_html"
