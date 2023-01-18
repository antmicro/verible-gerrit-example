#!/bin/bash

git checkout -b add-code$1
echo "module t; endmodule" > code$1.v
git add code$1.v
git commit -m "Add code"$1
git push origin HEAD:refs/for/master
