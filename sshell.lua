function ProcessInput(input)
    print(input);
end

function Run()
    print("Super Shell v1");
    while true do
        term.write("> ");
        local input = read();
        ProcessInput(input);
    end
end