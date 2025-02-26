#!/bin/bash

# Global flags for fast compile and debug compile
fast_compile="g++ -fdiagnostics-color=always -std=c++23 -Wshadow -Wall -Wno-unused-result -O2 -o"
debug_compile="g++ -DLOCAL -fdiagnostics-color=always -std=c++23 -Wshadow -Wall -g -fsanitize=address -fsanitize=undefined -fsanitize=signed-integer-overflow -D_GLIBCXX_DEBUG -o"

# Initialize default values
cpp_file=""
input_file=""
executable=""
compile_script=$fast_compile
run_only=false
add_testcase=false
mode="normal"

# stress testing default value
wrong="sol.cpp"
slow="slow.cpp"
generator="gen.cpp"
numberOFtest=100

# count number of test in this dir
count=$(ls sample*.in 2>/dev/null | wc -l)

# array for run specfic sample
specific_tests=()
contains() {
    local value="$1"
    for item in "${specific_tests[@]}"; do
        if [[ "$item" == "$value" ]]; then
            return 0  # Found
        fi
    done
    return 1  # Not found
}


# where problem will save (default : problem name, group : contest name, here : current dir)
io_location="name" 


# Function to handle invalid arguments
handle_invalid_argument() {
    echo -e "\033[1;31mError:\033[0m Invalid argument detected."
    # echo "Usage: ./runner.sh [options] <cpp-file>"
    echo -e "\033[1;33mAvailable options:\033[0m"
    echo "  --cp          Test your output"
    echo "  --parse       Parse problem set"
    echo "  --stress      Run stress testing"
    echo ""
    echo "Try './your_script.sh --help' for more information."
}

# Parse the command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            mode="help"
            shift
            ;;
        --parse)
            mode="parse"
            shift
            if [[ -n "$1" && ("$1" == "here" || "$1" == "group") ]]; then
                io_location="$1"
                shift
            fi
            ;;
        --stress)
            mode="stress"
            shift
            if [[ -n "$1" && "$1" != -* ]]; then wrong="$1"; shift; fi
            if [[ -n "$1" && "$1" != -* ]]; then slow="$1"; shift; fi
            if [[ -n "$1" && "$1" != -* ]]; then generator="$1"; shift; fi
            if [[ -n "$1" && "$1" != -* && $1 =~ ^[0-9]+$ ]]; then numberOFtest="$1"; shift; fi
            ;;
        --cp)
            mode="cp"
            shift
            while [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; do
                specific_tests+=("$1")
                shift
            done
            ;;
        -a)
            add_testcase=true;
            shift
            ;;
        -d)
            compile_script=$debug_compile
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
        *)
            handle_invalid_argument "$@"
            exit 1  # Call function to handle invalid arguments
            ;;
    esac
done

# help menu (need to update later)
if [[ "$mode" == "help" ]]; then
    echo -e "\033[1;34m"
    echo "╔══════════════════════════════════════════╗"
    echo "║         SCRIPT USAGE HELP MENU           ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "\033[0m"
    
    echo -e "\033[1;33mUsage:\033[0m"
    echo "  ./runner.sh [options] <cpp-file>"
    echo ""
    
    echo -e "\033[1;36mOptions:\033[0m"
    echo -e "  --help             Show help message."
    echo -e "  --stress           Run stress testing with four arguments: mysol, slowsol, generator, and number of tests."
    echo -e "  --cp <p/not>       Parse problem set ('p') or compare outputs ('not')."
    echo -e "  -d                 Use debug script for compilation."
    echo -e "  -r                 Run only (skip compilation if executable exists)."
    echo ""
    
    exit 0
fi

##### debug area#####
# echo "$run_only"



#################

if [[ "$mode" == "parse" ]]; then
    # fetch the problem 
    PORT=1327
    echo "Listening on port $PORT..."

    # Read the full HTTP request and extract the JSON body
    data=$(
        nc -l -p "$PORT" |                     # Listen for incoming request
        tr -d '\r' | sed '1,/^$/d' |           # Remove HTTP headers
        jq -c '.' 2>/dev/null                   # Parse and compact JSON
    )

    if [ -z "$data" ]; then 
    echo "No valid data received. Exiting..."
    exit 1
    fi

    # Parse problem data from the JSON
    problem_name=$(echo "$data" | jq -r '.name')
    contest_name=$(echo "$data" | jq -r '.group')
    url=$(echo "$data" | jq -r '.url')
    tests=$(echo "$data" | jq '.tests')

    contest_number=$(echo "$url" | grep -oE '[0-9]+' )

    echo "$url  $contest_number"

    # Ensure that the problem and contest names are present
    if [ -z "$problem_name" ] || [ -z "$contest_name" ]; then
        echo -e "\e[1;31mError:\e[1;37m Missing problem or contest name !!\e[0m"
        exit 1
    fi

    # Format contest and problem names for directory naming
    contest_name=$(echo "$contest_name" | sed -E 's/^[^ ]+ - (.*)$/\1/' | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
    problem_name=$(echo "$problem_name" | sed 's/[^a-zA-Z0-9.]//g' | tr -d ' ')

    if [[ "$contest_name" == *"Codeforces"* ]]; then
        contest_name="CF$contest_number"
    fi    

    # Create directory structure to save test cases
    
    dir="."
    if [[ "$io_location" == "name" ]]; then
        dir="${problem_name}"
    elif [[ "$io_location" == "group" ]]; then
        dir="${contest_name}/${problem_name}"
    fi
    mkdir -p "$dir"

    index=$(ls "$dir"/sample*.in 2>/dev/null | wc -l)
    if [[ "$index" -ne 0 ]]; then
        echo "⚠️ Found $index sample files."
        
        # Prompt user (delete by default)
        read -p "❓ Keep files? (Y/y to keep): " choice
        
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
    echo "✅ Saved ${dir}/input${index}.txt & ${dir}/output${index}.txt"

    ((index++))
    done

    echo "🔥 All test cases saved for: $problem_name ($contest_name)"

    # Exit after processing the data
    exit 0
fi


# maybe place somewhere
if [[ "$add_testcase" == true ]]; then
    echo -e "\033[1;34m🔄 Adding a new test case...\033[0m"
    
    # Generate new filenames
    new_input_file="sample$((count + 1)).in"
    new_output_file="sample$((count + 1)).out"
    
    # Prompt user for input and output file content
    echo -e "\033[1;33mPlease provide the input for the new test case:\033[0m"
    cat > "$new_input_file"  # Redirect user input to new input file
    
    echo -e "\033[1;33mPlease provide the expected output for the new test case:\033[0m"
    cat > "$new_output_file"  # Redirect user input to new output file
    
    echo -e "\033[1;32mTest case added successfully!\033[0m"
    echo -e "Input file: $new_input_file"
    echo -e "Output file: $new_output_file"
    
    # Increment count for future test cases
    count=$((count + 1))
fi


# If no cpp file is provided, show an error
if [[ "$mode" != "stress" ]]; then
    if [[ -z "$cpp_file" ]]; then
        echo -e "\033[0;31mError:\033[0m C++ file not provided !!"
        exit 1
    fi

    executable="${cpp_file%.cpp}"
    if [[ "$run_only" == false ]]; then
        $compile_script "$executable" "$cpp_file" &> compilation_output.log

        # Check for compilation errors
        if grep -q "error:" compilation_output.log; then
            echo -e "\033[1;31m❌ Compilation failed! Check errors below:\033[0m"
            cat compilation_output.log
            rm -f compilation_output.log
            exit 1
        fi

        # Check for warnings
        if grep -q "warning:" compilation_output.log; then
            echo -e "\033[1;33m⚠️ Compilation succeeded with warnings! Review them below:\033[0m"
            cat compilation_output.log | grep "warning:"
        else
            echo -e "\033[1;32m✅ Compilation successful with no warnings!\033[0m"
        fi
        rm -f compilation_output.log
    fi
fi

# Handle stress testing mode
if [[ "$mode" == "stress" ]]; then
    # echo "Running stress testing......"
    echo -e "\033[1;33m⏳ Running stress testing...\033[0m"
    # echo "Compiling solutions and generator....."

    # debug
    # echo "$Sol $slowSol $generator $num_tests $compile_script"
    
    # Compile all necessary files
    $compile_script wrong "$wrong"
    $compile_script slow "$slow"
    $compile_script generator "$generator"

    # Check if compilation was successful
    if [[ ! -f "Sol" || ! -f "slowSol" || ! -f "generator" ]]; then
        # echo "Compilation failed! Please check your code! Coooool brooo :)"
        echo -e "\033[0;31mCompilation failed! Please check your code! btw Coooool brooo :)\033[0m"
        exit 1
    fi

    echo -e "\033[1;32m✅ Compilation successful!\033[0m"
    
    # Run the stress testing for $total_tests times
    for ((testNum=1; testNum<=numberOFtest; testNum++)); do
        # Generate input using the generator
        ./generator > input
        
        # Run both solutions on the generated input
        ./slow < input > outSlow
        ./wrong < input > outWrong
        
        # Check if outputs are different
        if ! cmp -s "outWrong" "outSlow"; then
            echo -e "\033[1;31m❌ Error found in test #$testNum!\n\033[0m"
            echo -e "\033[1;33mInput:\033[0m"
            cat input
            echo -e "\033[1;31mWrong Output:\033[0m"
            cat outWrong
            echo -e "\033[1;32mExpected Output:\033[0m"
            cat outSlow

            echo -ne "\n\033[1;34mDo you want to add this test case? (Y/N): \033[0m"
            read -r isAdd

            # Check if user input is 'Y' or 'y'
            if [[ "$isAdd" != "N" && "$isAdd" != "n" ]]; then
                input_file="sample$((count + 1)).in"
                output_file="sample$((count + 1)).out"
                cp input "$input_file"
                cp outSlow "$output_file"
                echo -e "\033[1;32mTest case saved as $input_file and $output_file\033[0m"
            else
                echo -e "\033[1;31mSkipping test case addition.\033[0m"
            fi
                # Cleanup temporary files
                rm -f wrong slow generator input outSlow outWrong
            exit 1
        fi
    done

    echo -e "\033[1;32m✅ Passed $numberOFtest tests successfully!\n✅ Have a nice day && KEEP GRINDING!\033[0m"

    # Cleanup temporary files
    rm -f wrong slow generator input outSlow outWrong
    exit 0
fi

# Handle CP (Competitive Programming) mode
if [[ "$mode" == "cp" ]]; then
    echo -e "\033[1;36m❄️ Will your code be as sharp as VALYRIAN STEEL!!\n\033[0m"

    # Initialize counters
    total_tests=0
    passed_tests=0

    for input_file in $(ls sample*.in 2>/dev/null | sort -V); do
        [[ -f "$input_file" ]] || continue  # Skip if no input files exist

        index="${input_file//[^0-9]/}"  # input file index

        if [[ ${#specific_tests[@]} -gt 0 ]] && ! contains "$index"; then
            continue  # Skip this test case if it's not in the specified list
        fi

        output_file="${input_file%.in}.out"
        if [[ ! -f "$output_file" ]]; then
            echo -e "\033[1;31m⚠️ Error: Output file for test case $index not found!\033[0m"
            continue
        fi

        ((total_tests++))  # Increment total test count

        # Measure execution time of the code
        start_time=$(date +%s%N)  # Start time in nanoseconds
        ./"$executable" < "$input_file" > ans.out
        exit_code=$?
        end_time=$(date +%s%N)    # End time in nanoseconds

        # Calculate execution time in seconds
        execution_time=$((($end_time - $start_time) / 1000000))  # Time in milliseconds

        # if [[ $exit_code -ne 0 ]]; then
        #     echo -e "\033[1;31m⚠️ Sample #$index: RUNTIME ERROR\033[0m"
        # else
        #     if cmp -s ans.out "$output_file"; then
        #         ((passed_tests++)) 
        #         # echo -e "\033[1;37mTest case: $index\033[0m\n\033[1;33mTime: ${execution_time}ms\033[0m\n\033[1;32mVardict: ACCEPTED\n\033[0m"
        #         echo -e "\033[1;32m✅ Sample #$index: ACCEPTED\033[0m"
        #         echo -e "\033[1;33m⏳ Time: ${execution_time}ms\033[0m"
        #     else
        #         echo -e "\033[1;37m❌ Sample #$index\033[0m\n\033[1;33m⏳ Time: ${execution_time}ms\033[0m\n\033[1;31mVardict: WRONG ANSWER\033[0m"
        #         diff "$output_file" ans.out
        #         echo ""
        #     fi
        # fi


        if [[ $exit_code -ne 0 ]]; then
            echo -e "\033[1;37mSample Test #$index:\033[0m \033[1;31mRUNTIME ERROR\033[0m"
        else
            if cmp -s ans.out "$output_file"; then
                ((passed_tests++))
                echo -e "\033[1;37mSample Test #$index:\033[0m \033[1;32mACCEPTED\033[0m \033[1;33m(Time: ${execution_time}ms)\033[0m"
            else
                echo -e "\033[1;37mSample Test #$index:\033[0m \033[1;31mWRONG ANSWER\033[0m \033[1;33m(Time: ${execution_time}ms)\033[0m"
                echo -e "\033[1;31mWrong Output:\033[0m"
                cat ans.out
                echo -e "\033[1;32mExpected Output:\033[0m"
                cat "$output_file"
                diff "$output_file" ans.out
            fi
        fi

    done

        # Display summary with deep colors
        echo -ne "\n\033[1;36m📊 Summary: \033[0m"
        echo -e "\033[1;31m$((total_tests - passed_tests))\033[0m /\033[1;32m $passed_tests\033[0m / \033[1;37m$total_tests\033[0m"

        rm -f ans.out # remove answer of test case
        exit 0

    fi
fi

# Normal mode (compile and run the C++ file)
# executable="${cpp_file%.cpp}.out"



# Run the executable with input from terminal or input file
if [[ -n "$input_file" ]]; then
    ./"$executable" < "$input_file" > actual_output.txt
else
    ./"$executable" > actual_output.txt
fi

# Handle output destination
cat actual_output.txt

exit 0
