#!/bin/bash

# Global flags for fast compile and debug compile
fast_compile="g++ -fdiagnostics-color=always -std=c++23 -Wshadow -Wall -Wno-unused-result -O2 -o"
debug_compile="g++ -DLOCAL -fdiagnostics-color=always -std=c++23 -Wshadow -Wall -g -fsanitize=address -fsanitize=undefined -fsanitize=signed-integer-overflow -D_GLIBCXX_DEBUG -o"

# Initialize default values
mode=""
cpp_file=""
executable=""
run_only=false
add_testcase=false
compile_script=$fast_compile

# stress testing and validation default value
wrong="sol.cpp"
judge="judge.cpp"
generator="gen.cpp"
totalTest=100

# count number of test in this dir
count=$(ls sample*.in 2>/dev/null | wc -l)

# save all input file [NB : must use *.in]
input_files=()

# where problem will save (default : problem name, group : contest name, here : current dir)
sample_dir="name" 

# store specfic sample index for test 
multiple_solution=false
specific_tests=()
contains() {
    local value="$1"
    for item in "${specific_tests[@]}"; do
        if [[ "$item" == "$value" ]]; then
            return 0
        fi
    done
    return 1
}

help_menu() {
    echo -e "\033[1;34m"
    echo "╔══════════════════════════════════════════╗"
    echo "║         SCRIPT USAGE HELP MENU           ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "\033[0m"
    
    echo -e "\033[1;33mUsage:\033[0m"
    echo "  ./runner.sh [options] <cpp-file>"
    echo ""
    
    echo -e "\033[1;36mOptions:\033[0m"
    echo -e "  --help             Show this help message."
    echo -e "  --cp <tests>       Run competitive programming mode with optional specific test cases."
    echo -e "  --parse [here|group]  Parse input test cases from Competitive Companion."
    echo -e "                        'here' saves samples in the current directory."
    echo -e "                        'group' organizes samples into folders."
    echo -e "  --stress <mysol> <slowsol> <gen> <N>  Perform stress testing with a generator and N test cases."
    echo -e "  --validate <wrong> <validator> <gen> <N>  Validate a solution against a correct validator."
    echo -e "  -a                 Add a new test case manually."
    echo -e "  -d                 Use the debug script for compilation."
    echo -e "  -r                 Run only (skip compilation if executable exists)."
    echo ""
}

# Function to handle invalid arguments
handle_invalid_argument() {
    echo -e "\033[1;31mError:\033[0m Invalid argument detected."
    echo -e "\033[1;33mAvailable options:\033[0m"
    echo "--cp              Test your output"
    echo "--parse           Parse problem set"
    echo "--stress          Run stress testing"
    echo ""
    echo "Try './your_script.sh --help' for more information."
}


# Parse the command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            help_menu
            exit 0
            ;;
        --cp)
            mode="cp"
            shift
            while [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; do
                specific_tests+=("$1")
                shift
            done
            ;;
        --parse)
            mode="parse"
            shift
            if [[ -n "$1" && ("$1" == "here" || "$1" == "group") ]]; then
                sample_dir="$1"
                shift
            fi
            ;;
        --stress)
            mode="stress"
            shift
            if [[ -n "$1" && "$1" != -* ]]; then wrong="$1"; shift; fi
            if [[ -n "$1" && "$1" != -* ]]; then judge="$1"; shift; fi
            if [[ -n "$1" && "$1" != -* ]]; then generator="$1"; shift; fi
            if [[ -n "$1" && "$1" != -* && $1 =~ ^[0-9]+$ ]]; then totalTest="$1"; shift; fi
            ;;
        -a) 
            add_testcase=true;
            shift
            ;;
        -d)
            compile_script=$debug_compile
            shift
            ;;
        -m)
            multiple_solution=true
            shift
            ;;
        -r)
            run_only=true
            shift
            ;;
        *.cpp)
            cpp_file="$1"
            shift
            ;;
        *.in)
            input_files+=("$1")
            shift
            ;; 
        *)
            handle_invalid_argument 
            exit 1
            ;;
    esac
done

#debug
# echo "$specific_tests $run_only"

# parse the problem and exit 
if [[ "$mode" == "parse" ]]; then
    # fetch the problem 
    PORT=1327
    echo -e "\033[1;33m󰮏  Click the 'Parse Task (+)' button in your browser\033[0m"

    # Read the full HTTP request and extract the JSON body
    data=$(
        nc -l -p "$PORT" |                     # Listen for incoming request
        tr -d '\r' | sed '1,/^$/d' |           # Remove HTTP headers
        jq -c '.' 2>/dev/null                  # Parse and compact JSON
    )

    if [ -z "$data" ]; then 
    echo -e "\033[1;31m  No valid data received\033[0m"
    exit 1
    fi

    # Parse problem data from the JSON
    problem_name=$(echo "$data" | jq -r '.name')
    contest_name=$(echo "$data" | jq -r '.group')
    url=$(echo "$data" | jq -r '.url')
    tests=$(echo "$data" | jq '.tests')
    contest_number=$(echo "$url" | grep -oE '[0-9]+' )

    # Ensure that the problem and contest names are present
    # if [ -z "$problem_name" ] || [ -z "$contest_name" ]; then
    #     echo -e "\e\e[1;37m Missing problem or contest name !!\e[0m"
    #     exit 1
    # fi

    # Format contest and problem names for directory naming
    contest_name=$(echo "$contest_name" | sed -E 's/^[^ ]+ - (.*)$/\1/' | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
    problem_name=$(echo "$problem_name" | sed 's/[^a-zA-Z0-9.]//g' | tr -d ' ')

    # for codeforces used short form of contest name [ex : CF2072]
    # if you want full name just comment below line
    if [[ "$contest_name" == *"Codeforces"* ]]; then contest_name="CF$contest_number"; fi    

    # Create directory structure to save test cases
    dir="."
    if [[ "$sample_dir" == "name" ]]; then
        dir="${problem_name}"
    elif [[ "$sample_dir" == "group" ]]; then
        dir="${contest_name}/${problem_name}"
    fi
    mkdir -p "$dir"

    # check already have some sample in the directory 
    # [specially important when parse problem in current dir and already have some sample of another one]
    index=$(ls "$dir"/sample*.in 2>/dev/null | wc -l)
    if [[ "$index" -ne 0 ]]; then
        echo -e "  Found $index sample files"
        read -p $'\033[1;33m  Press (Y) to keep this sample: \033[0m' choice
        
        if [[ "$choice" != "Y" && "$choice" != "y" ]]; then
            rm -f "$dir"/sample*.{in,out}
            index=0
        fi
    fi

    ((index++))
    # Loop through each test case and save input/output files
    echo "$tests" | jq -c '.[]' | while read -r test; do
    input=$(echo "$test" | jq -r '.input')
    output=$(echo "$test" | jq -r '.output')

    # Save input and output to respective files
    echo "$input" > "${dir}/sample${index}.in"
    echo "$output" > "${dir}/sample${index}.out"
    echo -e "\033[0;37m󰄲  Saved ${dir}/sample${index}.in & ${dir}/sample${index}.out\033[0m"
    ((index++))
    done

    echo -e "\033[1;37m  All test cases saved for: $problem_name\033[0m"

    # Exit after processing the data
    exit 0
fi

# add test case manually
if [[ "$add_testcase" == true ]]; then
    echo -e "\033[0;37m  Adding a new test case...\033[0m"
    
    # Generate new filenames
    new_input_file="sample$((count + 1)).in"
    new_output_file="sample$((count + 1)).out"
    
    # Prompt user for input and output file content
    echo -e "\033[1;33m  Enter input (Ctrl + D to save):\033[0m"
    cat > "$new_input_file"  # Redirect user input to new input file

    echo -e "\033[1;33m  Enter expected output (Ctrl + D to save):\033[0m"
    cat > "$new_output_file"  # Redirect user input to new output file

    echo "󰄲  Test case added successfully"
    echo -e "\033[0;37m  Saved $new_input_file & $new_output_file.out\033[0m"

    # Increment count for future test cases
    count=$((count + 1))
fi

if [[ "$mode" != "stress" ]]; then
    # If no cpp file is provided, no further action can be taken
    if [[ -z "$cpp_file" || ! -f "$cpp_file" ]]; then
        echo -e "\033[0;31m  No C++ file provided or file not found\033[0m"
        exit 1
    fi

    executable="${cpp_file%.cpp}"
    if [[ "$run_only" == false || ! -f "$executable" ]]; then
        $compile_script "$executable" "$cpp_file" &> compilation_output.log

        # Check for compilation errors
        if grep -q "error:" compilation_output.log; then
            echo -e "\033[1;31m  Compilation failed\033[0m"
            cat compilation_output.log | grep "error:"
            rm -f compilation_output.log
            exit 1
        fi

        # Check for warnings
        if grep -q "warning:" compilation_output.log; then
            echo -e "\033[1;33m  Compilation warning\033[0m"
            cat compilation_output.log | grep "warning:"
        fi
        rm -f compilation_output.log
    fi
fi

# Handle CP (Competitive Programming) mode
if [[ "$mode" == "cp" ]]; then
    echo -e "\033[1;34m  Winter is coming.......\033[0m"

    # Initialize counters
    total_tests=0
    passed_tests=0
    for input_file in $(ls sample*.in 2>/dev/null | sort -V); do
        [[ -f "$input_file" ]] || continue  # Skip if no sample files exist

        index="${input_file//[^0-9]/}"  # input file index

        if [[ ${#specific_tests[@]} -gt 0 ]] && ! contains "$index"; then
            continue  # Skip this test case if it's not in the specified list
        fi

        output_file="${input_file%.in}.out"
        if [[ ! -f "$output_file" ]]; then
            echo -e "\033[0;31m  Error: Output file for test case $index not found!\033[0m"
            continue
        fi

        ((total_tests++))  # Increment total test count

        # Measure execution time of the code
        start_time=$(date +%s%N)
        ./"$executable" < "$input_file" > output.out
        exit_code=$?
        end_time=$(date +%s%N)
        execution_time=$((($end_time - $start_time) / 1000000))  # Time in milliseconds
        
        # checking runtime error 
        if [[ $exit_code -ne 0 ]]; then
            echo -e "\033[1;37m  Sample Test #$index:\033[0m \033[1;31mRUNTIME ERROR\033[0m"
            continue
        fi

        if [[ "$multiple_solution" == true ]]; then
            # multiple solution 
            if [[ ! -f "checker.cpp" ]]; then
                echo -e "\033[0;31m  checker.cpp is required for multiple solution [-m]\033[0m"
                exit 1
            fi

            $compile_script checker checker.cpp

            ./"$checker" < output.out > tmp1.out # unique solution
            mv tmp1.out output.out 

            ./"$checker" < "$output_file" > tmp2.out
            output_file="tmp2.out"
        fi
        
        if cmp -s output.out "$output_file"; then
            ((passed_tests++))
            echo -e "\033[1;37m󰄲  Sample Test #$index:\033[0m \033[1;32mACCEPTED\033[0m (\033[1;33mTime: ${execution_time}ms\033[0m)"
        else
            echo -e "\033[1;37m  Sample Test #$index:\033[0m \033[1;31mWRONG ANSWER\033[0m (\033[1;33mTime: ${execution_time}ms\033[0m)"
            echo -e "\033[4;36m\nInput:\033[0m"
            cat  "$input_file"
            # echo -e "\033[4;31mWrong Output:\033[0m"
            # cat  output.out
            # echo -e "\033[4;32mExpected Output:\033[0m"
            # cat  "$output_file"
            echo -e "\033[4;36mComparison:\033[0m"
            line_num=1  # Start line numbering
            exec 3<"$output_file" 4<"output.out"  # Open files for reading
            while true; do
                read -r o_line <&3
                read -r a_line <&4
                
                # Check if both files reached EOF
                if [[ -z "$o_line" && -z "$a_line" ]]; then
                    break
                fi

                # If one line is empty, print it as blank
                [[ -z "$o_line" ]] && o_line=" "  
                [[ -z "$a_line" ]] && a_line=" "

                if [[ "$o_line" == "$a_line" ]]; then
                    echo -e "L:$line_num || $o_line  |  \033[0;32m$a_line\033[0m"  # Green (Matching Answer)
                else
                    echo -e "L:$line_num || $o_line  |  \033[0;31m$a_line\033[0m"  # Red (Different Answer)
                fi

                ((line_num++))  # Increment line number
            done

            exec 3<&- 4<&-  # Close file descriptors
            echo ""
        fi
        
    done
    # Display summary 
    echo -ne "\033[1;36m  Final Score: \033[0m"
    echo -e "\033[1;31m$((total_tests - passed_tests))\033[0m /\033[1;32m $passed_tests\033[0m / \033[1;37m$total_tests\033[0m"

    rm -f output.out tmp2.out # remove output of test case
    exit 0
fi

# Handle stress testing mode
if [[ "$mode" == "stress" ]]; then
    
    # Compile all necessary files
    $compile_script wrong "$wrong"
    $compile_script judge "$judge"
    $compile_script generator "$generator"

    # Check if compilation was successful
    if [[ ! -f "wrong" || ! -f "judge" || ! -f "generator" ]]; then
        echo -e "\033[1;31m  Compilation failed\033[0m"
        exit 1
    fi

    # echo -e "\033[1;34m  Running stress testing...\033[0m"
    echo -e "\033[1;34m  You win or you die.......\033[0m"
    
    # Run the stress testing for $totalTest times
    for ((testNum=1; testNum<=totalTest; testNum++)); do
        ./generator > input # Generate input file
        ./wrong < input > outWrong # answer from my solution

        bad=false

        if [[ "$multiple_solution" == true ]]; then
            # multiple solution
            cat input outWrong > data # merge input and output
            ./judge < data > outJudge # answer from judge solution
            if [[ "$(cat outJudge)" != "OK" ]]; then
                echo -e "\033[0;31m  Error found in test #$testNum!\n\033[0m"
                echo -e "\033[4;36mInput:\033[0m"
                cat input
                echo -e "\033[4;31mWrong Output:\033[0m"
                cat outWrong
                echo -e "\033[4;32mJudge Result:\033[0m"
                cat outJudge

                bad=true
            fi
        else
            ./judge < input > outJudge
            if !(cmp -s "outWrong" "outJudge") 
            then
                echo -e "\033[0;31m  Error found in test #$testNum!\n\033[0m"
                echo -e "\033[4;36mInput:\033[0m"
                cat input
                echo -e "\033[4;31mWrong Output:\033[0m"
                cat outWrong
                echo -e "\033[4;32mExpected Output:\033[0m"
                cat outJudge

                bad=true
            fi
        fi
        
        if [[ "$bad" == true ]]; then
            echo -ne "\n\033[1;33m  Do you want to add this test case? (Y/N): \033[0m"
            read -r isAdd

            if [[ "$isAdd" != "N" && "$isAdd" != "n" ]]; then
                input_file="sample$((count + 1)).in"
                output_file="sample$((count + 1)).out"
                cp input "$input_file"
                cp outJudge "$output_file"
                echo "  Saved $input_file & $output_file.out"
            else
                echo -e "  Skipped"
            fi
            rm -f wrong judge generator input outjudge outWrong data 
            exit 1
        fi
    done

    echo -e "\033[1;32m󰄲  Passed $totalTest tests successfully!\033[0m"

    # Cleanup temporary files
    rm -f wrong judge generator input outjudge outWrong data 
    exit 0
fi


# if no mode set run the executable with input from terminal or input file [run one by one from input_files=()]
if [[ ${#input_files[@]} -eq 0 ]]; then
    ./"$executable" > output.out
    exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo -e "\033[1;31m  RUNTIME ERROR\033[0m"
    else
        echo -e "\033[4;35mOutput:\033[0m"
        cat output.out
        rm -f output.out
    fi
else
    for input_file in "${input_files[@]}"; do
        echo -e "\033[1;34m  Running with input: $input_file\033[0m"
        # Measure execution time of the code
        start_time=$(date +%s%N) 
        ./"$executable" < "$input_file" > output.out
        exit_code=$?
        end_time=$(date +%s%N)   
        execution_time=$((($end_time - $start_time) / 1000000))
        if [[ $exit_code -ne 0 ]]; then
            echo -e "\033[1;31m  RUNTIME ERROR\033[0m"
            echo -e "\033[4;36mInput:\033[0m"
            cat "$input_file"
            
        else
            echo -e "\033[4;35mOutput:\033[0m"
            cat output.out
            echo -e "\033[1;33m󱦟 Time: $execution_time ms\033[0m"
            rm -f output.out
        fi
    done
fi
exit 0
