#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/src/parser.sh"

cat << 'EOF' > /tmp/overview_test.html
<section id="inst56041" class=" block block_myoverview  card mb-3" role="complementary" data-block="myoverview" aria-labelledby="instance-56041-header">
    <div class="card-body p-3" id="yui_3_17_2_1_1786898538384_153">
            <h5 id="instance-56041-header" class="card-title d-inline">Course overview</h5>
        <div class="card-text content mt-3" id="yui_3_17_2_1_1786898538384_152">
            <div id="block-myoverview-6a81e86aed2896a81e86ada0dd6" class="block-myoverview block-cards" data-region="myoverview" role="navigation" data-init="true">
            <div data-region="filter" class="d-flex align-items-center flex-wrap" aria-label="Course overview controls" id="yui_3_17_2_1_1786898538384_151">
                <div class="dropdown m-b-1 mr-auto" id="yui_3_17_2_1_1786898538384_150">
                    <button id="groupingdropdown" type="button" class="btn btn-outline-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" aria-label="Grouping dropdown">
                        <i class="icon fa fa-filter fa-fw " aria-hidden="true"></i>
                        <span class="d-sm-inline-block" data-active-item-text="">
                            All
                        </span>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item active" href="#" data-filter="grouping" data-value="all">All</a></li>
                        <li><a class="dropdown-item " href="#" data-filter="grouping" data-value="inprogress">In progress</a></li>
                        <li><a class="dropdown-item " href="#" data-filter="grouping" data-value="future">Future</a></li>
                        <li><a class="dropdown-item " href="#" data-filter="grouping" data-value="past">Past</a></li>
                        <li><a class="dropdown-item " href="#" data-filter="grouping" data-value="favourites">Starred</a></li>
                        <li><a class="dropdown-item " href="#" data-filter="grouping" data-value="hidden">Hidden</a></li>
                    </ul>
                </div>
            </div>

    <div class="container-fluid p-0">
        <div id="courses-view-6a81e86aed2896a81e86ada0dd6">
<div data-region="paged-content-page" data-page="1">
        <div role="list">
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
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9335">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9335" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>
            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9335" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">English Communication Skills II - B</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9393">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9393" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>
            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9393" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">Introduction to Linux - A</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9354">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9354" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>
            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9354" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">LCPC Course</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9116">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9116" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>
            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9116" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">Operating Systems - A</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9083">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9083" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>
            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9083" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">Religion and Public Life - A</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9039">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9039" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>
            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9039" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">Software Engineering - A</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div class="course-summaryitem m-b-1 p-2" role="listitem" data-region="course-content" data-course-id="9234">
        <div class="d-flex">
            <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9234" tabindex="-1">
                <div class="summaryimage rounded-circle m-r-1">
                    <span class="sr-only">Course image</span>
                </div>
            </a>
            <div class="align-self-stretch d-flex flex-column w-100">
                <div class="d-flex mb-1">
                    <a href="https://moodle.usal.edu.lb/lms/course/view.php?id=9234" class="coursename">
                        <span class="sr-only">Course name</span>
                        <h6 class="d-inline h5">Web Application Development - B</h6>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
        </div>
    </div>
    </div>
</section>
EOF

source "$BASE_DIR/src/browser_engine.sh"
source "$BASE_DIR/src/renderer.sh"

current_url="https://moodle.usal.edu.lb/lms/my/"
adapter_parse_to_elements "$(cat /tmp/overview_test.html)"
render_page
