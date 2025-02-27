﻿// --------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
// --------------------------------------------------------------------------------------------

using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Microsoft.Oryx.SharedCodeGenerator.Outputs
{
    [OutputType("shell")]
    internal class ShellOutput : IOutputFile
    {
        private const char NewLine = '\n';
        private ConstantCollection collection;
        private string directory;
        private string fileNamePrefix;

        public void Initialize(ConstantCollection constantCollection, Dictionary<string, string> typeInfo)
        {
            this.collection = constantCollection;
            this.directory = typeInfo["directory"];
            this.fileNamePrefix = typeInfo["file-name-prefix"];
        }

        public string GetPath()
        {
            var name = this.collection.Name.Camelize();
            name = char.ToLowerInvariant(name[0]) + name.Substring(1);
            return Path.Combine(this.directory, this.fileNamePrefix + name + ".sh");
        }

        public string GetContent()
        {
            StringBuilder body = new StringBuilder();
            body.Append("# " + Program.BuildAutogenDisclaimer(this.collection.SourcePath) + NewLine); // Can't use AppendLine becuase it appends \r\n
            body.Append(NewLine);
            if (this.collection.StringConstants?.Any() ?? false)
            {
                foreach (var constant in this.collection.StringConstants)
                {
                    string name = constant.Key.Replace(ConstantCollection.NameSeparator[0], '_').ToUpper();
                    var value = constant.Value.WrapValueInQuotes();

                    // Ex: PYTHON_VERSION='3.7.7'
                    body.Append($"{name}={value}{NewLine}");
                }
            }

            return body.ToString();
        }
    }
}
