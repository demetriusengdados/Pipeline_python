jobs:
  level0:
    name: level0
    runs-on: ubuntu-latest

    strategy:
      fail-fast: false
      matrix:
          region: ["westus2"]
          convention: ["random", "cafrandom"]

    container:
      image: aztfmod/rover:2005.1510
      options: --user 0

    steps:
      - name: Login azure
        run: |
          az login --service-principal -u '${{ env.ARM_CLIENT_ID }}' -p '${{ env.ARM_CLIENT_SECRET }}' --tenant '${{ env.ARM_TENANT_ID }}'
          az account set -s  ${{ env.ARM_SUBSCRIPTION_ID }}

          echo "local user: $(whoami)"

      - name: Locate launchpad
        run: |
         id=$(az storage account list --query "[?tags.tfstate=='level0' && tags.workspace=='level0']" -o json | jq -r .[0].id)
          if [ "${id}" == "null" ]; then
            /tf/rover/launchpad.sh /tf/launchpads/launchpad_opensource plan -var location=${{ matrix.region }}
            /tf/rover/launchpad.sh /tf/launchpads/launchpad_opensource apply -var location=${{ matrix.region }}
          fi

caf_foundations:
    name: caf_foundations
    runs-on: ubuntu-latest
    needs: level0

    strategy:
      fail-fast: false
      matrix:
          landingzone: ["landingzone_caf_foundations"]
          region: ["westus2"]
          convention: ["random"]
          environment: ["integration-tests"]

    container:
      image: aztfmod/rover:2005.1510
      options: --user 0

    steps:
      - uses: actions/checkout@v2

      - name:  setup context
        id: context
        run: |
          ln -s ${GITHUB_WORKSPACE} /tf/caf
          echo "ls /tf/caf" && ls -lsa /tf/caf
          ls -lsa /tmp

          workspace='caffoundationsci'
          echo ::set-env name=TF_VAR_workspace::${workspace}

      - name: Login azure
        run: |
          az login --service-principal -u '${{ env.ARM_CLIENT_ID }}' -p '${{ env.ARM_CLIENT_SECRET }}' --tenant '${{ env.ARM_TENANT_ID }}'
          az account set -s  ${{ env.ARM_SUBSCRIPTION_ID }}

          echo "local user: $(whoami)"

      - name: workspace
        run: |
          /tf/rover/launchpad.sh workspace create ${TF_VAR_workspace}

      - name: deploy caf_foundations
        run: |
            /tf/rover/rover.sh /tf/caf/${{ matrix.landingzone }} apply \
                '-var tags={testing-job-id="${{ github.run_id }}"}' \
                '-var-file ${{ env.TFVARS_PATH }}/${{ matrix.environment }}/${{ matrix.landingzone }}/${{ matrix.landingzone }}_${{ matrix.region }}_${{ matrix.convention }}.tfvars'

 landingzones:
    name: landingzones
    runs-on: ubuntu-latest

    needs: [level0, caf_foundations]

    strategy:
      fail-fast: false
      matrix:
          landingzone: ["landingzone_hub_spoke", "landingzone_secure_vnet_dmz", "landingzone_starter", "landingzone_vdc_demo"]
          region: ["westus2"]
          convention: ["cafrandom", "random"]
          environment: ["integration-tests"]

    container:
      image: aztfmod/rover:2005.1510
      options: --user 0

    steps:
      - uses: actions/checkout@v2

      - name:  setup context
        id: context
        run: |
          ln -s ${GITHUB_WORKSPACE} /tf/caf
          echo "ls /tf/caf" && ls -lsa /tf/caf
          ls -lsa /tmp

          job_id=${{ job.container.id }}
          workspace=${job_id:0:63}
          echo ::set-env name=TF_VAR_workspace::${workspace}

      - name: Login azure
        run: |
          az login --service-principal -u '${{ env.ARM_CLIENT_ID }}' -p '${{ env.ARM_CLIENT_SECRET }}' --tenant '${{ env.ARM_TENANT_ID }}'
          az account set -s  ${{ env.ARM_SUBSCRIPTION_ID }}

          echo "local user: $(whoami)"

      - name: workspace
        run: |
          /tf/rover/launchpad.sh workspace create ${TF_VAR_workspace}

      - name: deploy landing_zone
        run: |
          /tf/rover/rover.sh /tf/caf/${{ matrix.landingzone }} apply \
            '-var tags={testing-job-id="${{ github.run_id }}"}' \
            '-var-file ${{ env.TFVARS_PATH }}/${{ matrix.environment }}/${{ matrix.landingzone }}/${{ matrix.landingzone }}.tfvars' \
            '-var workspace=caffoundationsci'

      - name: destroy landing_zone
        if: always()
        run: |
          /tf/rover/rover.sh /tf/caf/${{ matrix.landingzone }} destroy \
            '-var tags={testing-job-id="${{ github.run_id }}"}' \
            '-var-file ${{ env.TFVARS_PATH }}/${{ matrix.environment }}/${{ matrix.landingzone }}/${{ matrix.landingzone }}.tfvars' \
            '-var workspace=caffoundationsci'

      - name: cleanup workspace
        if: always()
        run: |
          stg_name=$(az storage account list --query "[?tags.tfstate=='level0']" -o json | jq -r .[0].name)
          az storage container delete --account-name ${stg_name} --name ${TF_VAR_workspace} --auth-mode login

level0_destroy:
    name: level0_destroy
    runs-on: ubuntu-latest

    needs: caf_foundations_destroy

    strategy:
      fail-fast: false
      matrix:
          region: ["westus2"]
          convention: ["random", "cafrandom"]

    container:
      image: aztfmod/rover:2005.1510
      options: --user 0

    steps:
      - name: Login azure
        run: |
          az login --service-principal -u '${{ env.ARM_CLIENT_ID }}' -p '${{ env.ARM_CLIENT_SECRET }}' --tenant '${{ env.ARM_TENANT_ID }}'
          az account set -s  ${{ env.ARM_SUBSCRIPTION_ID }}

          echo "local user: $(whoami)"

      - name: Remove launchpad
        run: |
            /tf/rover/launchpad.sh /tf/launchpads/launchpad_opensource destroy -var location=${{ matrix.region }} -auto-approve

      - name: Complete purge
        run: |
            for i in `az group list -o tsv --query '[].name'`; do az group delete -n $i -y --no-wait; done
            for i in `az monitor log-profiles list -o tsv --query '[].name'`; do az monitor log-profiles delete --name $i -y; done

